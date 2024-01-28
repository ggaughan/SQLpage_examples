// todo greg: move elsewhere?
document.addEventListener("fragment-loaded", (e) => {
    htmx.process(e.target);
});