<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Détour - Gestion des Colis & Cargo</title>
  <link rel="icon" href="/logo.jpeg" type="image/jpeg">
  <!-- Tailwind CSS CDN pour une mise en page rapide et propre -->
  <script src="https://cdn.tailwindcss.com"></script>
  <!-- Lucide Icons pour des icônes modernes -->
  <script src="https://unpkg.com/lucide@latest"></script>
  <!-- Chart.js pour les graphiques du rapport -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
  <style>
    :root {
      --navy: #0b1c3d;
      --red: #e62335;
      --red-hover: #cc1b2c;
    }
    .bg-navy { background-color: var(--navy); }
    .text-navy { color: var(--navy); }
    .bg-red-custom { background-color: var(--red); }
    .bg-red-custom:hover { background-color: var(--red-hover); }
    .border-navy { border-color: var(--navy); }
    @media print {
      header, #btnDashboard, #btnRapport, #btnNouveauColis, #dashboardView, #packageModal { display: none !important; }
      #reportView { display: block !important; }
      body { background: white; }
    }
  </style>
</head>
<body class="bg-slate-100 text-slate-800 font-sans antialiased min-h-screen flex flex-col">

  <!-- Header -->
  <header class="bg-navy text-white shadow-md">
    <div class="max-w-7xl mx-auto px-4 py-4 flex justify-between items-center">
      <div class="flex items-center space-x-3">
        <img src="/logo.jpeg" alt="Détour Agence de Voyage" class="h-14 w-auto bg-white rounded-lg px-2 py-1 object-contain">
        <div>
          <h1 class="text-lg font-bold leading-none">Gestion des Colis</h1>
          <p class="text-xs text-slate-300">Espace Administration & Suivi</p>
        </div>
      </div>
      <div class="flex items-center space-x-3">
        <button id="btnRapport" onclick="showReport()" class="bg-white/10 hover:bg-white/20 text-white px-4 py-2 rounded-lg font-medium shadow flex items-center space-x-2 transition border border-white/20">
          <i data-lucide="bar-chart-3" class="w-5 h-5"></i>
          <span>Rapport</span>
        </button>
        <button id="btnDashboard" onclick="showDashboard()" class="hidden bg-white/10 hover:bg-white/20 text-white px-4 py-2 rounded-lg font-medium shadow flex items-center space-x-2 transition border border-white/20">
          <i data-lucide="layout-dashboard" class="w-5 h-5"></i>
          <span>Tableau de bord</span>
        </button>
        <button id="btnNouveauColis" onclick="openModal()" class="bg-red-custom text-white px-4 py-2 rounded-lg font-medium shadow flex items-center space-x-2 transition">
          <i data-lucide="package-plus" class="w-5 h-5"></i>
          <span>Nouveau Colis</span>
        </button>
      </div>
    </div>
  </header>

  <!-- Contenu Principal : Tableau de bord -->
  <main id="dashboardView" class="max-w-7xl mx-auto px-4 py-8 flex-1 w-full space-y-6">

    <!-- Cartes Statisiques -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <div class="bg-white p-5 rounded-xl shadow-sm border border-slate-200 flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-slate-500">Total Expéditions</p>
          <h3 class="text-2xl font-bold text-slate-800 mt-1" id="stat-total">0</h3>
        </div>
        <div class="bg-blue-50 text-blue-600 p-3 rounded-lg">
          <i data-lucide="boxes" class="w-6 h-6"></i>
        </div>
      </div>

      <div class="bg-white p-5 rounded-xl shadow-sm border border-slate-200 flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-slate-500">En Enregistrement</p>
          <h3 class="text-2xl font-bold text-amber-600 mt-1" id="stat-enregistre">0</h3>
        </div>
        <div class="bg-amber-50 text-amber-600 p-3 rounded-lg">
          <i data-lucide="archive-restore" class="w-6 h-6"></i>
        </div>
      </div>

      <div class="bg-white p-5 rounded-xl shadow-sm border border-slate-200 flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-slate-500">En Transit / Arrivé</p>
          <h3 class="text-2xl font-bold text-indigo-600 mt-1" id="stat-transit">0</h3>
        </div>
        <div class="bg-indigo-50 text-indigo-600 p-3 rounded-lg">
          <i data-lucide="plane-takeoff" class="w-6 h-6"></i>
        </div>
      </div>

      <div class="bg-white p-5 rounded-xl shadow-sm border border-slate-200 flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-slate-500">Livrés</p>
          <h3 class="text-2xl font-bold text-emerald-600 mt-1" id="stat-livre">0</h3>
        </div>
        <div class="bg-emerald-50 text-emerald-600 p-3 rounded-lg">
          <i data-lucide="check-circle" class="w-6 h-6"></i>
        </div>
      </div>
    </div>

    <!-- Filtres et Recherche -->
    <div class="bg-white p-4 rounded-xl shadow-sm border border-slate-200 flex flex-col md:flex-row gap-4 justify-between items-center">
      <div class="relative w-full md:w-96">
        <i data-lucide="search" class="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"></i>
        <input type="text" id="searchInput" oninput="renderPackages()" placeholder="Rechercher par N° de suivi, client..." class="w-full pl-10 pr-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-navy focus:border-transparent">
      </div>
      <div class="flex items-center space-x-3 w-full md:w-auto">
        <label for="statusFilter" class="text-sm font-medium text-slate-600 whitespace-nowrap">Filtrer par statut :</label>
        <select id="statusFilter" onchange="renderPackages()" class="w-full md:w-auto border border-slate-300 rounded-lg px-3 py-2 bg-white focus:outline-none focus:ring-2 focus:ring-navy">
          <option value="ALL">Tous les statuts</option>
          <option value="Enregistré">Enregistré</option>
          <option value="En transit">En transit</option>
          <option value="Arrivé au pays">Arrivé au pays</option>
          <option value="En livraison">En livraison</option>
          <option value="Livré">Livré</option>
        </select>
      </div>
    </div>

    <!-- Tableau des Colis -->
    <div class="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-500 uppercase tracking-wider">
              <th class="p-4">N° de Suivi</th>
              <th class="p-4">Expéditeur / Destinataire</th>
              <th class="p-4">Trajet</th>
              <th class="p-4">Statut Actuel</th>
              <th class="p-4 text-center">Mise à jour rapide</th>
              <th class="p-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody id="packageTableBody" class="divide-y divide-slate-100 text-sm">
            <!-- Rempli en JavaScript -->
          </tbody>
        </table>
      </div>
    </div>
  </main>

  <!-- Contenu Principal : Rapport -->
  <main id="reportView" class="hidden max-w-7xl mx-auto px-4 py-8 flex-1 w-full space-y-6">

    <!-- En-tête du rapport -->
    <div class="bg-white p-6 rounded-xl shadow-sm border border-slate-200 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
      <div>
        <h2 class="text-2xl font-bold text-navy flex items-center gap-2">
          <i data-lucide="file-bar-chart" class="w-7 h-7"></i>
          Rapport complet des expéditions
        </h2>
        <p class="text-sm text-slate-500 mt-1" id="reportDate"></p>
      </div>
      <div class="flex gap-3">
        <button onclick="exportReportCSV()" class="px-4 py-2 border border-slate-300 rounded-lg text-slate-600 hover:bg-slate-50 font-medium flex items-center gap-2 text-sm">
          <i data-lucide="download" class="w-4 h-4"></i>
          Exporter CSV
        </button>
        <button onclick="window.print()" class="px-4 py-2 bg-navy text-white rounded-lg font-medium flex items-center gap-2 text-sm">
          <i data-lucide="printer" class="w-4 h-4"></i>
          Imprimer
        </button>
      </div>
    </div>

    <!-- KPIs du rapport -->
    <div class="grid grid-cols-2 md:grid-cols-5 gap-4" id="reportKpis"></div>

    <!-- Graphiques -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div class="bg-white p-5 rounded-xl shadow-sm border border-slate-200">
        <h3 class="text-sm font-semibold text-slate-600 uppercase mb-4">Répartition par statut</h3>
        <div class="h-64 flex items-center justify-center">
          <canvas id="chartStatus"></canvas>
        </div>
      </div>
      <div class="bg-white p-5 rounded-xl shadow-sm border border-slate-200">
        <h3 class="text-sm font-semibold text-slate-600 uppercase mb-4">Top destinations</h3>
        <div class="h-64">
          <canvas id="chartDestinations"></canvas>
        </div>
      </div>
      <div class="bg-white p-5 rounded-xl shadow-sm border border-slate-200 lg:col-span-2">
        <h3 class="text-sm font-semibold text-slate-600 uppercase mb-4">Expéditions par date</h3>
        <div class="h-64">
          <canvas id="chartTimeline"></canvas>
        </div>
      </div>
    </div>

    <!-- Tableaux -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div class="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
        <div class="px-5 py-4 border-b border-slate-200 bg-slate-50">
          <h3 class="font-semibold text-slate-700">Synthèse par statut</h3>
        </div>
        <div class="overflow-x-auto">
          <table class="w-full text-left text-sm">
            <thead>
              <tr class="border-b border-slate-100 text-xs font-semibold text-slate-500 uppercase">
                <th class="p-3">Statut</th>
                <th class="p-3 text-center">Nombre</th>
                <th class="p-3 text-right">Part (%)</th>
              </tr>
            </thead>
            <tbody id="reportStatusTable"></tbody>
          </table>
        </div>
      </div>
      <div class="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
        <div class="px-5 py-4 border-b border-slate-200 bg-slate-50">
          <h3 class="font-semibold text-slate-700">Top trajets</h3>
        </div>
        <div class="overflow-x-auto">
          <table class="w-full text-left text-sm">
            <thead>
              <tr class="border-b border-slate-100 text-xs font-semibold text-slate-500 uppercase">
                <th class="p-3">Trajet</th>
                <th class="p-3 text-center">Colis</th>
                <th class="p-3 text-right">Livrés</th>
              </tr>
            </thead>
            <tbody id="reportRoutesTable"></tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Tableau détaillé complet -->
    <div class="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
      <div class="px-5 py-4 border-b border-slate-200 bg-slate-50 flex justify-between items-center">
        <h3 class="font-semibold text-slate-700">Liste complète des expéditions</h3>
        <span class="text-xs text-slate-500" id="reportTotalLabel"></span>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse text-sm">
          <thead>
            <tr class="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-500 uppercase tracking-wider">
              <th class="p-3">N° Suivi</th>
              <th class="p-3">Expéditeur</th>
              <th class="p-3">Contact exp.</th>
              <th class="p-3">Destinataire</th>
              <th class="p-3">Contact dest.</th>
              <th class="p-3">Trajet</th>
              <th class="p-3">Date</th>
              <th class="p-3">Statut</th>
            </tr>
          </thead>
          <tbody id="reportFullTable" class="divide-y divide-slate-100"></tbody>
        </table>
      </div>
    </div>
  </main>

  <!-- Modal : Nouveau Colis -->
  <div id="packageModal" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm hidden flex items-center justify-center p-4 z-50">
    <div class="bg-white rounded-xl shadow-2xl max-w-xl w-full overflow-hidden max-h-[90vh] overflow-y-auto">
      <div class="bg-navy text-white px-6 py-4 flex justify-between items-center">
        <h2 id="modalTitle" class="text-lg font-bold">Enregistrer un nouveau colis</h2>
        <button onclick="closeModal()" class="text-slate-300 hover:text-white">
          <i data-lucide="x" class="w-6 h-6"></i>
        </button>
      </div>
      
      <form id="addPackageForm" onsubmit="handleSavePackage(event)" class="p-6 space-y-4">
        <input type="hidden" id="editingId" value="">
        <div>
          <label class="block text-xs font-semibold text-slate-600 uppercase mb-1">N° de suivi (généré ou personnalisé)</label>
          <input type="text" id="trackingCode" required placeholder="Ex: DETOURSN-004" class="w-full border border-slate-300 rounded-lg p-2.5 font-mono focus:ring-2 focus:ring-navy focus:outline-none">
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-xs font-semibold text-slate-600 uppercase mb-1">Nom Expéditeur</label>
            <input type="text" id="senderName" required placeholder="Ex: Jean Dupont" class="w-full border border-slate-300 rounded-lg p-2.5 focus:ring-2 focus:ring-navy focus:outline-none">
          </div>
          <div>
            <label class="block text-xs font-semibold text-slate-600 uppercase mb-1">Nom Destinataire</label>
            <input type="text" id="receiverName" required placeholder="Ex: Aliou Ndiaye" class="w-full border border-slate-300 rounded-lg p-2.5 focus:ring-2 focus:ring-navy focus:outline-none">
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-xs font-semibold text-slate-600 uppercase mb-1">Contact expéditeur <span class="text-slate-400 font-normal normal-case">(optionnel)</span></label>
            <input type="text" id="senderContact" placeholder="Ex: +221 77 123 45 67" class="w-full border border-slate-300 rounded-lg p-2.5 focus:ring-2 focus:ring-navy focus:outline-none">
          </div>
          <div>
            <label class="block text-xs font-semibold text-slate-600 uppercase mb-1">Contact destinataire <span class="text-slate-400 font-normal normal-case">(optionnel)</span></label>
            <input type="text" id="receiverContact" placeholder="Ex: +221 76 987 65 43" class="w-full border border-slate-300 rounded-lg p-2.5 focus:ring-2 focus:ring-navy focus:outline-none">
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-xs font-semibold text-slate-600 uppercase mb-1">Ville Départ</label>
            <input type="text" id="origin" required placeholder="Ex: Paris" class="w-full border border-slate-300 rounded-lg p-2.5 focus:ring-2 focus:ring-navy focus:outline-none">
          </div>
          <div>
            <label class="block text-xs font-semibold text-slate-600 uppercase mb-1">Ville Arrivée</label>
            <input type="text" id="destination" required placeholder="Ex: Dakar" class="w-full border border-slate-300 rounded-lg p-2.5 focus:ring-2 focus:ring-navy focus:outline-none">
          </div>
        </div>

        <div>
          <label class="block text-xs font-semibold text-slate-600 uppercase mb-1">Statut Initial</label>
          <select id="initialStatus" class="w-full border border-slate-300 rounded-lg p-2.5 focus:ring-2 focus:ring-navy focus:outline-none bg-white">
            <option value="Enregistré">Enregistré</option>
            <option value="En transit">En transit</option>
            <option value="Arrivé au pays">Arrivé au pays</option>
            <option value="En livraison">En livraison</option>
            <option value="Livré">Livré</option>
          </select>
        </div>

        <div class="flex justify-end space-x-3 pt-4 border-t border-slate-100">
          <button type="button" onclick="closeModal()" class="px-4 py-2 border border-slate-300 rounded-lg text-slate-600 hover:bg-slate-50 font-medium">Annuler</button>
          <button type="submit" class="px-4 py-2 bg-red-custom text-white rounded-lg font-medium shadow">Enregistrer le colis</button>
        </div>
      </form>
    </div>
  </div>

  <script>
    const API = "/api";
    let packages = [];
    const statuses = ["Enregistré", "En transit", "Arrivé au pays", "En livraison", "Livré"];
    const statusColors = {
      "Enregistré": "#64748b",
      "En transit": "#2563eb",
      "Arrivé au pays": "#9333ea",
      "En livraison": "#d97706",
      "Livré": "#059669"
    };

    let chartInstances = {};

    async function apiFetch(url, options = {}) {
      const res = await fetch(url, {
        headers: { "Content-Type": "application/json" },
        ...options
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || "Erreur serveur");
      return data;
    }

    async function loadPackages() {
      packages = await apiFetch(`${API}/packages`);
      renderPackages();
    }

    // Initialisation
    document.addEventListener("DOMContentLoaded", async () => {
      lucide.createIcons();
      try {
        await loadPackages();
      } catch (err) {
        alert("Impossible de charger les colis : " + err.message);
      }
    });

    function showDashboard() {
      document.getElementById("dashboardView").classList.remove("hidden");
      document.getElementById("reportView").classList.add("hidden");
      document.getElementById("btnRapport").classList.remove("hidden");
      document.getElementById("btnDashboard").classList.add("hidden");
      document.getElementById("btnNouveauColis").classList.remove("hidden");
      lucide.createIcons();
    }

    function showReport() {
      document.getElementById("dashboardView").classList.add("hidden");
      document.getElementById("reportView").classList.remove("hidden");
      document.getElementById("btnRapport").classList.add("hidden");
      document.getElementById("btnDashboard").classList.remove("hidden");
      document.getElementById("btnNouveauColis").classList.add("hidden");
      renderReport();
      lucide.createIcons();
    }

    function renderReport() {
      const now = new Date();
      document.getElementById("reportDate").textContent =
        `Généré le ${now.toLocaleDateString("fr-FR", { weekday: "long", day: "numeric", month: "long", year: "numeric" })} à ${now.toLocaleTimeString("fr-FR", { hour: "2-digit", minute: "2-digit" })}`;

      renderReportKpis();
      renderReportCharts();
      renderReportTables();
    }

    function renderReportKpis() {
      const total = packages.length;
      const delivered = packages.filter(p => p.status === "Livré").length;
      const inProgress = packages.filter(p => !["Livré", "Enregistré"].includes(p.status)).length;
      const registered = packages.filter(p => p.status === "Enregistré").length;
      const deliveryRate = total > 0 ? Math.round((delivered / total) * 100) : 0;

      const kpis = [
        { label: "Total colis", value: total, color: "text-slate-800", bg: "bg-blue-50 text-blue-600", icon: "boxes" },
        { label: "Enregistrés", value: registered, color: "text-amber-600", bg: "bg-amber-50 text-amber-600", icon: "archive-restore" },
        { label: "En cours", value: inProgress, color: "text-indigo-600", bg: "bg-indigo-50 text-indigo-600", icon: "plane-takeoff" },
        { label: "Livrés", value: delivered, color: "text-emerald-600", bg: "bg-emerald-50 text-emerald-600", icon: "check-circle" },
        { label: "Taux livraison", value: `${deliveryRate}%`, color: "text-navy", bg: "bg-slate-100 text-navy", icon: "percent" }
      ];

      document.getElementById("reportKpis").innerHTML = kpis.map(k => `
        <div class="bg-white p-4 rounded-xl shadow-sm border border-slate-200 flex items-center justify-between">
          <div>
            <p class="text-xs font-medium text-slate-500">${k.label}</p>
            <h3 class="text-xl font-bold ${k.color} mt-0.5">${k.value}</h3>
          </div>
          <div class="${k.bg} p-2.5 rounded-lg">
            <i data-lucide="${k.icon}" class="w-5 h-5"></i>
          </div>
        </div>
      `).join("");
    }

    function renderReportCharts() {
      Object.values(chartInstances).forEach(c => c.destroy());
      chartInstances = {};

      // Graphique statuts (donut)
      const statusCounts = statuses.map(s => packages.filter(p => p.status === s).length);
      chartInstances.status = new Chart(document.getElementById("chartStatus"), {
        type: "doughnut",
        data: {
          labels: statuses,
          datasets: [{
            data: statusCounts,
            backgroundColor: statuses.map(s => statusColors[s]),
            borderWidth: 2,
            borderColor: "#fff"
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: { position: "bottom", labels: { boxWidth: 12, padding: 12, font: { size: 11 } } }
          }
        }
      });

      // Graphique destinations (bar)
      const destMap = {};
      packages.forEach(p => { destMap[p.destination] = (destMap[p.destination] || 0) + 1; });
      const sortedDests = Object.entries(destMap).sort((a, b) => b[1] - a[1]).slice(0, 8);

      chartInstances.destinations = new Chart(document.getElementById("chartDestinations"), {
        type: "bar",
        data: {
          labels: sortedDests.map(d => d[0]),
          datasets: [{
            label: "Colis",
            data: sortedDests.map(d => d[1]),
            backgroundColor: "#0b1c3d",
            borderRadius: 6
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: { legend: { display: false } },
          scales: {
            y: { beginAtZero: true, ticks: { stepSize: 1 } },
            x: { grid: { display: false } }
          }
        }
      });

      // Graphique timeline (line)
      const dateMap = {};
      packages.forEach(p => { dateMap[p.date] = (dateMap[p.date] || 0) + 1; });
      const sortedDates = Object.entries(dateMap).sort((a, b) => a[0].localeCompare(b[0]));

      chartInstances.timeline = new Chart(document.getElementById("chartTimeline"), {
        type: "line",
        data: {
          labels: sortedDates.map(d => {
            const [y, m, day] = d[0].split("-");
            return `${day}/${m}/${y}`;
          }),
          datasets: [{
            label: "Expéditions",
            data: sortedDates.map(d => d[1]),
            borderColor: "#e62335",
            backgroundColor: "rgba(230, 35, 53, 0.1)",
            fill: true,
            tension: 0.3,
            pointRadius: 5,
            pointBackgroundColor: "#e62335"
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: { legend: { display: false } },
          scales: {
            y: { beginAtZero: true, ticks: { stepSize: 1 } }
          }
        }
      });
    }

    function renderReportTables() {
      const total = packages.length;

      // Table statuts
      document.getElementById("reportStatusTable").innerHTML = statuses.map(s => {
        const count = packages.filter(p => p.status === s).length;
        const pct = total > 0 ? ((count / total) * 100).toFixed(1) : "0.0";
        return `
          <tr class="border-b border-slate-50 hover:bg-slate-50/50">
            <td class="p-3">
              <span class="inline-flex items-center gap-2">
                <span class="w-2.5 h-2.5 rounded-full" style="background:${statusColors[s]}"></span>
                ${s}
              </span>
            </td>
            <td class="p-3 text-center font-semibold">${count}</td>
            <td class="p-3 text-right text-slate-500">${pct}%</td>
          </tr>`;
      }).join("");

      // Table trajets
      const routeMap = {};
      packages.forEach(p => {
        const key = `${p.origin} → ${p.destination}`;
        if (!routeMap[key]) routeMap[key] = { total: 0, delivered: 0 };
        routeMap[key].total++;
        if (p.status === "Livré") routeMap[key].delivered++;
      });
      const sortedRoutes = Object.entries(routeMap).sort((a, b) => b[1].total - a[1].total);

      document.getElementById("reportRoutesTable").innerHTML = sortedRoutes.length
        ? sortedRoutes.map(([route, data]) => `
          <tr class="border-b border-slate-50 hover:bg-slate-50/50">
            <td class="p-3 font-medium">${route}</td>
            <td class="p-3 text-center font-semibold">${data.total}</td>
            <td class="p-3 text-right text-emerald-600 font-medium">${data.delivered}</td>
          </tr>`).join("")
        : `<tr><td colspan="3" class="p-4 text-center text-slate-400">Aucun trajet enregistré</td></tr>`;

      // Table complète
      document.getElementById("reportTotalLabel").textContent = `${total} expédition${total > 1 ? "s" : ""}`;
      document.getElementById("reportFullTable").innerHTML = packages.length
        ? packages.map(pkg => `
          <tr class="hover:bg-slate-50/80">
            <td class="p-3 font-mono font-bold text-navy text-xs">${pkg.code}</td>
            <td class="p-3">${pkg.sender}</td>
            <td class="p-3 text-slate-500">${pkg.senderContact || "—"}</td>
            <td class="p-3">${pkg.receiver}</td>
            <td class="p-3 text-slate-500">${pkg.receiverContact || "—"}</td>
            <td class="p-3 text-slate-600">${pkg.origin} → ${pkg.destination}</td>
            <td class="p-3 text-slate-500">${formatDate(pkg.date)}</td>
            <td class="p-3">
              <span class="px-2 py-0.5 text-xs font-semibold rounded-full border ${getBadgeClass(pkg.status)}">${pkg.status}</span>
            </td>
          </tr>`).join("")
        : `<tr><td colspan="8" class="p-6 text-center text-slate-400">Aucune expédition enregistrée</td></tr>`;
    }

    function formatDate(dateStr) {
      const [y, m, d] = dateStr.split("-");
      return `${d}/${m}/${y}`;
    }

    function exportReportCSV() {
      const headers = ["N° Suivi", "Expéditeur", "Contact expéditeur", "Destinataire", "Contact destinataire", "Origine", "Destination", "Date", "Statut"];
      const rows = packages.map(p => [p.code, p.sender, p.senderContact || "", p.receiver, p.receiverContact || "", p.origin, p.destination, p.date, p.status]);
      const csv = [headers, ...rows].map(r => r.map(c => `"${c}"`).join(";")).join("\n");
      const blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
      const link = document.createElement("a");
      link.href = URL.createObjectURL(blob);
      link.download = `rapport-detour-${new Date().toISOString().split("T")[0]}.csv`;
      link.click();
    }

    function getBadgeClass(status) {
      switch (status) {
        case "Enregistré": return "bg-slate-100 text-slate-700 border-slate-300";
        case "En transit": return "bg-blue-50 text-blue-700 border-blue-200";
        case "Arrivé au pays": return "bg-purple-50 text-purple-700 border-purple-200";
        case "En livraison": return "bg-amber-50 text-amber-700 border-amber-200";
        case "Livré": return "bg-emerald-50 text-emerald-700 border-emerald-200";
        default: return "bg-slate-100 text-slate-600";
      }
    }

    function renderPackages() {
      const tbody = document.getElementById("packageTableBody");
      const search = document.getElementById("searchInput").value.toLowerCase();
      const filter = document.getElementById("statusFilter").value;

      tbody.innerHTML = "";

      const filtered = packages.filter(pkg => {
        const matchesSearch = pkg.code.toLowerCase().includes(search) || 
                              pkg.sender.toLowerCase().includes(search) || 
                              pkg.receiver.toLowerCase().includes(search) ||
                              (pkg.senderContact || "").toLowerCase().includes(search) ||
                              (pkg.receiverContact || "").toLowerCase().includes(search);
        const matchesFilter = filter === "ALL" || pkg.status === filter;
        return matchesSearch && matchesFilter;
      });

      filtered.forEach(pkg => {
        const row = document.createElement("tr");
        row.className = "hover:bg-slate-50/80 transition";
        row.innerHTML = `
          <td class="p-4 font-mono font-bold text-navy">${pkg.code}</td>
          <td class="p-4">
            <div class="font-medium text-slate-900">${pkg.receiver}</div>
            ${pkg.receiverContact ? `<div class="text-xs text-slate-500">${pkg.receiverContact}</div>` : ""}
            <div class="text-xs text-slate-400">De: ${pkg.sender}${pkg.senderContact ? ` · ${pkg.senderContact}` : ""}</div>
          </td>
          <td class="p-4 text-slate-600">
            <span class="font-medium">${pkg.origin}</span> &rarr; <span class="font-medium">${pkg.destination}</span>
          </td>
          <td class="p-4">
            <span class="px-2.5 py-1 text-xs font-semibold rounded-full border ${getBadgeClass(pkg.status)}">
              ${pkg.status}
            </span>
          </td>
          <td class="p-4 text-center">
            <select onchange="updateStatus('${pkg.id}', this.value)" class="text-xs border border-slate-300 rounded px-2 py-1 bg-white focus:ring-1 focus:ring-navy">
              ${statuses.map(st => `<option value="${st}" ${st === pkg.status ? 'selected' : ''}>${st}</option>`).join('')}
            </select>
          </td>
          <td class="p-4 text-right">
            <button onclick="deletePackage('${pkg.id}')" class="text-red-500 hover:text-red-700 p-1 rounded hover:bg-red-50 transition" title="Supprimer">
              <i data-lucide="trash-2" class="w-4 h-4"></i>
            </button>
          </td>
        `;
        tbody.appendChild(row);
      });

      lucide.createIcons();
      updateStats();
    }

    function updateStats() {
      document.getElementById("stat-total").innerText = packages.length;
      document.getElementById("stat-enregistre").innerText = packages.filter(p => p.status === "Enregistré").length;
      document.getElementById("stat-transit").innerText = packages.filter(p => p.status === "En transit" || p.status === "Arrivé au pays").length;
      document.getElementById("stat-livre").innerText = packages.filter(p => p.status === "Livré").length;
    }

    async function updateStatus(id, newStatus) {
      try {
        await apiFetch(`${API}/packages/${id}`, {
          method: "PATCH",
          body: JSON.stringify({ status: newStatus })
        });
        await loadPackages();
      } catch (err) {
        alert(err.message);
      }
    }

    async function deletePackage(id) {
      if (!confirm("Voulez-vous vraiment supprimer ce colis ?")) return;
      try {
        await apiFetch(`${API}/packages/${id}`, { method: "DELETE" });
        await loadPackages();
      } catch (err) {
        alert(err.message);
      }
    }

    function nextTrackingCode() {
      const nums = packages
        .map(p => p.code.match(/^DETOURSN-(\d+)$/i))
        .filter(Boolean)
        .map(m => parseInt(m[1], 10));
      const next = nums.length ? Math.max(...nums) + 1 : 1;
      return `DETOURSN-${String(next).padStart(3, "0")}`;
    }

    function openModal() {
      document.getElementById("trackingCode").value = nextTrackingCode();
      document.getElementById("packageModal").classList.remove("hidden");
    }

    function closeModal() {
      document.getElementById("packageModal").classList.add("hidden");
      document.getElementById("addPackageForm").reset();
    }

    async function handleCreatePackage(event) {
      event.preventDefault();
      const newPkg = {
        code: document.getElementById("trackingCode").value,
        sender: document.getElementById("senderName").value,
        receiver: document.getElementById("receiverName").value,
        senderContact: document.getElementById("senderContact").value.trim(),
        receiverContact: document.getElementById("receiverContact").value.trim(),
        origin: document.getElementById("origin").value,
        destination: document.getElementById("destination").value,
        status: document.getElementById("initialStatus").value,
        date: new Date().toISOString().split("T")[0]
      };

      try {
        await apiFetch(`${API}/packages`, {
          method: "POST",
          body: JSON.stringify(newPkg)
        });
        await loadPackages();
        closeModal();
      } catch (err) {
        alert(err.message);
      }
    }
  </script>
</body>
</html>
