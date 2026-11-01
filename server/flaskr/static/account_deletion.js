const form = document.querySelector("#account-deletion-form");
const message = document.querySelector("#account-deletion-message");

form.addEventListener("submit", async (event) => {
  event.preventDefault();

  if (!window.confirm(form.dataset.confirm)) {
    return;
  }

  const submitButton = form.querySelector('button[type="submit"]');
  submitButton.disabled = true;
  message.textContent = form.dataset.deleting;

  try {
    const response = await fetch(form.action, {
      method: "DELETE",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email: form.elements.email.value,
        password: form.elements.password.value,
      }),
    });

    if (response.status === 204) {
      form.hidden = true;
      message.textContent = form.dataset.success;
    } else if (response.status === 401) {
      message.textContent = form.dataset.invalidCredentials;
      submitButton.disabled = false;
    } else {
      message.textContent = form.dataset.failure;
      submitButton.disabled = false;
    }
  } catch {
    message.textContent = form.dataset.connectionFailure;
    submitButton.disabled = false;
  }
});
