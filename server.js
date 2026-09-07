const express = require("express");
const cors = require("cors");
const fs = require("fs");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;
const DATA_FILE = path.join(__dirname, "data", "packages.json");
const QUOTES_FILE = path.join(__dirname, "data", "quotes.json");
const PUBLIC_DIR = path.join(__dirname, "public");

const STATUSES = ["Enregistré", "En transit", "Arrivé au pays", "En livraison", "Livré"];
const CODE_PREFIX = "DETOURSN-";

function nextTrackingCode(packages) {
  const nums = packages
    .map(p => p.code.match(/^DETOURSN-(\d+)$/i))
    .filter(Boolean)
    .map(m => parseInt(m[1], 10));
  const next = nums.length ? Math.max(...nums) + 1 : 1;
  return `${CODE_PREFIX}${String(next).padStart(3, "0")}`;
}

app.use(cors());
app.use(express.json());
app.use(express.static(PUBLIC_DIR));

function readPackages() {
  try {
    const raw = fs.readFileSync(DATA_FILE, "utf8");
    return JSON.parse(raw);
  } catch {
    return [];
  }
}

function writePackages(packages) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(packages, null, 2), "utf8");
}

function readQuotes() {
  try {
    const raw = fs.readFileSync(QUOTES_FILE, "utf8");
    return JSON.parse(raw);
  } catch {
    return [];
  }
}

function writeQuotes(quotes) {
  fs.writeFileSync(QUOTES_FILE, JSON.stringify(quotes, null, 2), "utf8");
}

// ——— API publique : suivi client ———
app.get("/api/track/:code", (req, res) => {
  const code = req.params.code.trim().toUpperCase();
  const packages = readPackages();
  const pkg = packages.find(p => p.code.toUpperCase() === code);

  if (!pkg) {
    return res.status(404).json({ error: "Numéro de suivi introuvable." });
  }

  res.json({
    code: pkg.code,
    status: pkg.status,
    origin: pkg.origin,
    destination: pkg.destination,
    receiver: pkg.receiver,
    date: pkg.date,
    step: STATUSES.indexOf(pkg.status)
  });
});

// ——— API admin ———
app.get("/api/packages", (_req, res) => {
  res.json(readPackages());
});

app.post("/api/packages", (req, res) => {
  const packages = readPackages();
  const { code, sender, receiver, senderContact, receiverContact, origin, destination, status, date } = req.body;

  if (!code || !sender || !receiver || !origin || !destination) {
    return res.status(400).json({ error: "Champs obligatoires manquants." });
  }

  if (packages.some(p => p.code.toUpperCase() === code.toUpperCase())) {
    return res.status(409).json({ error: "Ce numéro de suivi existe déjà." });
  }

  const newPkg = {
    id: Date.now().toString(),
    code: (code || nextTrackingCode(packages)).trim().toUpperCase(),
    sender,
    receiver,
    origin,
    destination,
    status: status || "Enregistré",
    date: date || new Date().toISOString().split("T")[0]
  };

  if (senderContact?.trim()) newPkg.senderContact = senderContact.trim();
  if (receiverContact?.trim()) newPkg.receiverContact = receiverContact.trim();

  packages.unshift(newPkg);
  writePackages(packages);
  res.status(201).json(newPkg);
});

app.patch("/api/packages/:id", (req, res) => {
  const packages = readPackages();
  const index = packages.findIndex(p => p.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ error: "Colis introuvable." });
  }

  const { code, sender, receiver, senderContact, receiverContact, origin, destination, status } = req.body;

  if (status && !STATUSES.includes(status)) {
    return res.status(400).json({ error: "Statut invalide." });
  }

  if (code) {
    const normalized = code.trim().toUpperCase();
    const duplicate = packages.some(p => p.id !== req.params.id && p.code.toUpperCase() === normalized);
    if (duplicate) {
      return res.status(409).json({ error: "Ce numéro de suivi existe déjà." });
    }
  }

  const updated = { ...packages[index] };

  if (code !== undefined) updated.code = code.trim().toUpperCase();
  if (sender !== undefined) updated.sender = sender;
  if (receiver !== undefined) updated.receiver = receiver;
  if (origin !== undefined) updated.origin = origin;
  if (destination !== undefined) updated.destination = destination;
  if (status !== undefined) updated.status = status;

  if ("senderContact" in req.body) {
    if (senderContact?.trim()) updated.senderContact = senderContact.trim();
    else delete updated.senderContact;
  }
  if ("receiverContact" in req.body) {
    if (receiverContact?.trim()) updated.receiverContact = receiverContact.trim();
    else delete updated.receiverContact;
  }

  packages[index] = updated;
  writePackages(packages);
  res.json(updated);
});

app.delete("/api/packages/:id", (req, res) => {
  const packages = readPackages();
  const filtered = packages.filter(p => p.id !== req.params.id);

  if (filtered.length === packages.length) {
    return res.status(404).json({ error: "Colis introuvable." });
  }

  writePackages(filtered);
  res.json({ ok: true });
});

// ——— API Demandes de devis ———
app.get("/api/quotes", (_req, res) => {
  res.json(readQuotes());
});

app.post("/api/quotes", (req, res) => {
  const quotes = readQuotes();
  const { name, nom, phone, tel, email, service, offre, message, personnes, date } = req.body;

  const clientName = (name || nom || "").trim();
  const clientPhone = (phone || tel || "").trim();

  if (!clientName || !clientPhone) {
    return res.status(400).json({ error: "Le nom et le numéro de téléphone sont obligatoires." });
  }

  const newQuote = {
    id: Date.now().toString(),
    name: clientName,
    phone: clientPhone,
    email: (email || "").trim(),
    service: (service || offre || "Général").trim(),
    message: (message || "").trim(),
    personnes: personnes || null,
    dateSouhaitee: date || null,
    status: "Nouveau",
    createdAt: new Date().toISOString()
  };

  quotes.unshift(newQuote);
  writeQuotes(quotes);
  res.status(201).json(newQuote);
});

app.patch("/api/quotes/:id", (req, res) => {
  const quotes = readQuotes();
  const index = quotes.findIndex(q => q.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ error: "Demande de devis introuvable." });
  }

  const { status, notes } = req.body;
  const quote = quotes[index];

  if (status !== undefined) quote.status = status;
  if (notes !== undefined) quote.notes = notes;

  quotes[index] = quote;
  writeQuotes(quotes);
  res.json(quote);
});

app.delete("/api/quotes/:id", (req, res) => {
  const quotes = readQuotes();
  const filtered = quotes.filter(q => q.id !== req.params.id);

  if (filtered.length === quotes.length) {
    return res.status(404).json({ error: "Demande de devis introuvable." });
  }

  writeQuotes(filtered);
  res.json({ ok: true });
});

app.listen(PORT, () => {
  console.log(`Détour Suivi Colis & Devis → http://localhost:${PORT}`);
  console.log(`API suivi client → http://localhost:${PORT}/api/track/DETOURSN-001`);
  console.log(`API devis → http://localhost:${PORT}/api/quotes`);
});
