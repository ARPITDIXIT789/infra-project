// Ansible + Terraform + Jenkins - Web Deploy
document.addEventListener('DOMContentLoaded', function () {
    console.log('🚀 Site deployed successfully via Ansible + Terraform + Jenkins!');

    // Show deployment timestamp
    const footer = document.querySelector('.footer');
    if (footer) {
        const now = new Date().toLocaleString();
        footer.innerHTML += '<br>Page loaded at: ' + now;
    }
});
