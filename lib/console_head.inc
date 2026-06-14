[!] Shared page shell — dark sidebar + topbar, Bootstrap 5.3. Server-rendered
    multi-page model: one WebDNA template per page; the sidebar links to real
    URLs; the active item is highlighted by the page setting [text]nav=...[/text]
    before this include. Set [text]page_title=...[/text] too. Closed by
    lib/console_foot.inc.
    NOTE: Bootstrap/icons/font load from CDN — fine for an internal console (the
    browser has internet); vendor them locally before prod. [/!]
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Console — [page_title]</title>
<link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.3/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link href="/assets/css/custom.css" rel="stylesheet">
<!-- favicons (assets/favicon) -->
<link rel="shortcut icon" href="/assets/favicon/favicon.ico">
<link rel="icon" type="image/png" sizes="16x16" href="/assets/favicon/favicon-16x16.png">
<link rel="icon" type="image/png" sizes="32x32" href="/assets/favicon/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="96x96" href="/assets/favicon/favicon-96x96.png">
<link rel="icon" type="image/png" sizes="128x128" href="/assets/favicon/favicon-128.png">
<link rel="icon" type="image/png" sizes="196x196" href="/assets/favicon/favicon-196x196.png">
<link rel="apple-touch-icon" sizes="57x57" href="/assets/favicon/apple-touch-icon-57x57.png">
<link rel="apple-touch-icon" sizes="60x60" href="/assets/favicon/apple-touch-icon-60x60.png">
<link rel="apple-touch-icon" sizes="72x72" href="/assets/favicon/apple-touch-icon-72x72.png">
<link rel="apple-touch-icon" sizes="76x76" href="/assets/favicon/apple-touch-icon-76x76.png">
<link rel="apple-touch-icon" sizes="114x114" href="/assets/favicon/apple-touch-icon-114x114.png">
<link rel="apple-touch-icon" sizes="120x120" href="/assets/favicon/apple-touch-icon-120x120.png">
<link rel="apple-touch-icon" sizes="144x144" href="/assets/favicon/apple-touch-icon-144x144.png">
<link rel="apple-touch-icon" sizes="152x152" href="/assets/favicon/apple-touch-icon-152x152.png">
<meta name="msapplication-TileColor" content="#dd0000">
<meta name="msapplication-TileImage" content="/assets/favicon/mstile-144x144.png">
<meta name="msapplication-config" content="/assets/favicon/browserconfig.xml">
</head>
<body>
<div class="app">
  <aside class="sidebar" id="sidebar">
    <div class="brand"><img class="logo" src="/assets/images/webdna-o.svg" alt="WebDNA" width="26" height="26"> Cloud Console</div>

    <div class="nav-group">Overview</div>
    <a class="nav-link[switch value=[nav]][case value=overview] active[/case][/switch]" href="/"><i class="bi bi-grid-1x2"></i> Dashboard</a>

    <div class="nav-group">Compute</div>
    <a class="nav-link[switch value=[nav]][case value=linodes] active[/case][/switch]" href="/linodes"><i class="bi bi-hdd-stack"></i> Linodes</a>
    <a class="nav-link[switch value=[nav]][case value=backups] active[/case][/switch]" href="/backups"><i class="bi bi-shield-check"></i> Backups</a>
    <a class="nav-link[switch value=[nav]][case value=images] active[/case][/switch]" href="/images"><i class="bi bi-disc"></i> Linux Images</a>

    <div class="nav-group">Networking</div>
    <a class="nav-link[switch value=[nav]][case value=firewalls] active[/case][/switch]" href="/firewalls"><i class="bi bi-bricks"></i> Firewalls</a>
    <a class="nav-link[switch value=[nav]][case value=dns] active[/case][/switch]" href="/dns"><i class="bi bi-globe2"></i> DNS Manager</a>
    <a class="nav-link[switch value=[nav]][case value=nodebalancers] active[/case][/switch]" href="/nodebalancers"><i class="bi bi-diagram-3"></i> NodeBalancers</a>

    <div class="nav-group">Storage</div>
    <a class="nav-link[switch value=[nav]][case value=object] active[/case][/switch]" href="/object-storage"><i class="bi bi-bucket"></i> Object Storage</a>
    <a class="nav-link[switch value=[nav]][case value=block] active[/case][/switch]" href="/block-storage"><i class="bi bi-device-hdd"></i> Block Storage</a>

    <div class="nav-group">Account</div>
    <a class="nav-link[switch value=[nav]][case value=clients] active[/case][/switch]" href="/clients"><i class="bi bi-people"></i> Clients</a>
  </aside>

  <div class="main">
    <div class="topbar">
      <button class="btn btn-sm btn-light d-md-none" onclick="document.getElementById('sidebar').classList.toggle('open')"><i class="bi bi-list"></i></button>
      <div class="search">
        <div class="input-group input-group-sm">
          <span class="input-group-text bg-transparent border-0"><i class="bi bi-search text-muted"></i></span>
          <input class="form-control form-control-sm" placeholder="Search Linodes, domains, buckets&hellip;" disabled>
        </div>
      </div>
      <div class="region-pill"><i class="bi bi-geo-alt-fill text-success"></i> Select Region</div>
      <div class="ms-auto d-flex align-items-center gap-2">
        <div class="dropdown">
          <button class="btn btn-sm btn-success btn-create dropdown-toggle" data-bs-toggle="dropdown"><i class="bi bi-plus-lg"></i> Create</button>
          <ul class="dropdown-menu dropdown-menu-end">
            <li><span class="dropdown-item-text legend">Provisioning actions &mdash; not implemented</span></li>
          </ul>
        </div>
        <div class="rounded-circle bg-dark text-white d-grid" style="width:32px;height:32px;place-items:center;font-size:.8rem;">RS</div>
      </div>
    </div>
    <div class="content">
