let sliders = ['vehicle','parked','ped','scene','police'];
const defaultValues = {vehicle: 1, parked: 1, ped: 1, scene: 1, police: 1};
let langs = {};
let currentLang = 'fr';

function setLanguage(lang) {
    currentLang = lang || 'fr';
    let t = langs[currentLang];
    if (!t) t = langs['fr'];
    if (!t) {
        document.getElementById('menu-title').innerHTML = `<span>🛣️</span>`;
        document.getElementById('label-vehicle').textContent = "Vehicles";
        document.getElementById('label-parked').textContent = "Parked";
        document.getElementById('label-peds').textContent = "Peds";
        document.getElementById('label-scenario').textContent = "Scenario";
        document.getElementById('label-police').textContent = "Police";
        document.getElementById('reset').textContent = "Reset";
        document.getElementById('save').textContent = "Apply";
        document.getElementById('close').textContent = "Close";
        document.getElementById('ui-credit').textContent = "";
        document.getElementById('lang-label').textContent = "Language :";
        return;
    }
    document.getElementById('menu-title').innerHTML = `<span>${t.menu_icon || "🛣️"}</span>`;
    document.getElementById('label-vehicle').textContent = t.vehicles || "Vehicles";
    document.getElementById('label-parked').textContent = t.parked || "Parked";
    document.getElementById('label-peds').textContent = t.peds || "Peds";
    document.getElementById('label-scenario').textContent = t.scenario_peds || "Scenario";
    document.getElementById('label-police').textContent = t.police || "Police";
    document.getElementById('reset').textContent = t.reset || "Reset";
    document.getElementById('save').textContent = t.save || "Apply";
    document.getElementById('close').textContent = t.close || "Close";
    document.getElementById('ui-credit').textContent = t.menu_credit || "";
    document.getElementById('lang-label').textContent = (t.language || "Language") + " :";
}

function updateSliderValues() {
    sliders.forEach(sl => {
        document.getElementById('val-'+sl).textContent = parseFloat(document.getElementById(sl).value).toFixed(2);
    });
}
sliders.forEach(sl => {
    let slider = document.getElementById(sl);
    slider.addEventListener('input', updateSliderValues);
    slider.addEventListener('input', () => sendDensities(true));
});

function getCurrentDensities() {
    return {
        vehicle: parseFloat(document.getElementById('vehicle').value),
        parked: parseFloat(document.getElementById('parked').value),
        ped: parseFloat(document.getElementById('ped').value),
        scene: parseFloat(document.getElementById('scene').value),
        police: parseFloat(document.getElementById('police').value),
    }
}
function sendDensities(temp) {
    fetch(`https://${GetParentResourceName()}/${temp ? 'setDensities' : 'saveDensities'}`, {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({ densities: getCurrentDensities() })
    });
}
document.getElementById('save').onclick = function() { sendDensities(false); }
document.getElementById('reset').onclick = function() {
    sliders.forEach(sl => { document.getElementById(sl).value = defaultValues[sl]; });
    updateSliderValues();
    sendDensities(false);
};
function closeMenu() {
    document.getElementById('container').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/close`, {method:"POST"});
}
document.getElementById('close').onclick = closeMenu;
document.getElementById('lang').onchange = function() {
    setLanguage(this.value);
    fetch(`https://${GetParentResourceName()}/switchLang`, {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({ lang: this.value })
    });
    localStorage.setItem('menu_traffic_lang', this.value);
}
window.addEventListener('keydown', function(e) { if (e.key === "Escape") closeMenu(); });
window.addEventListener('message', (event) => {
    if (event.data && event.data.action === "setLangs") {
        langs = event.data.langs || langs;
        setLanguage(event.data.current || "fr");
        document.getElementById('lang').value = event.data.current || "fr";
    }
    if (event.data && event.data.action === "setLang") {
        setLanguage(event.data.lang);
        document.getElementById('lang').value = event.data.lang;
    }
    if (event.data && event.data.action === "openMenu") {
        document.getElementById('container').style.display = 'flex';
        document.body.style.overflow = "hidden";
        let saved = localStorage.getItem('menu_traffic_lang');
        if(saved && langs[saved]) setLanguage(saved),document.getElementById('lang').value=saved
        else setLanguage(currentLang);
    }
    if (event.data && event.data.action === "closeMenu") {
        document.getElementById('container').style.display = 'none';
        document.body.style.overflow = "hidden";
    }
});
window.addEventListener('DOMContentLoaded', updateSliderValues);
document.getElementById('container').style.display = 'none';
document.body.style.overflow = "hidden";
