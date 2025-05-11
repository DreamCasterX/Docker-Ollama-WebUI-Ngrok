document.addEventListener("DOMContentLoaded", () => {
  // DOM Elements
  const apiKeyContainer = document.getElementById("api-key-container");
  const chatContainer = document.getElementById("chat-container");
  const apiKeyInput = document.getElementById("api-key-input");
  const submitApiKeyBtn = document.getElementById("submit-api-key");
  const chatMessages = document.getElementById("chat-messages");
  const userInput = document.getElementById("user-input");
  const sendButton = document.getElementById("send-button");

  // Variables
  let apiKey = "";
  const baseUrl = "http://localhost:8080";
  const modelId = "customer-support-agent";

  // Event Listeners
  submitApiKeyBtn.addEventListener("click", handleApiKeySubmit);
  sendButton.addEventListener("click", handleSendMessage);
  userInput.addEventListener("keypress", (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  });

  // Functions
  function handleApiKeySubmit() {
    const key = apiKeyInput.value.trim();
    if (!key) {
      showError(apiKeyContainer, "Please enter a valid API key");
      return;
    }

    // Validate API key by making a test request
    validateApiKey(key)
      .then((valid) => {
        if (valid) {
          apiKey = key;
          apiKeyContainer.classList.add("hidden");
          chatContainer.classList.remove("hidden");
        } else {
          showError(apiKeyContainer, "Invalid API key. Please try again.");
        }
      })
      .catch((error) => {
        console.error("Error validating API key:", error);
        showError(
          apiKeyContainer,
          "Error validating API key. Please try again."
        );
      });
  }

  async function validateApiKey(key) {
    try {
      const response = await fetch(`${baseUrl}/api/models`, {
        method: "GET",
        headers: {
          Authorization: `Bearer ${key}`,
          Accept: "application/json",
        },
      });
      return response.ok;
    } catch (error) {
      console.error("API key validation error:", error);
      return false;
    }
  }

  function handleSendMessage() {
    const message = userInput.value.trim();
    if (!message) return;

    // Add user message to chat
    addMessageToChat("user", message);
    userInput.value = "";

    // Add loading indicator
    const loadingElement = addLoadingIndicator();

    // Send message to API
    sendMessageToAPI(message)
      .then((response) => {
        // Remove loading indicator
        loadingElement.remove();

        // Add response to chat
        if (response) {
          addMessageToChat("system", response);
        } else {
          addMessageToChat(
            "system",
            "Sorry, I encountered an error processing your request. Please try again."
          );
        }
      })
      .catch((error) => {
        console.error("Error sending message:", error);
        loadingElement.remove();
        addMessageToChat(
          "system",
          "Sorry, I encountered an error processing your request. Please try again."
        );
      });
  }

  async function sendMessageToAPI(message) {
    try {
      const response = await fetch(`${baseUrl}/api/chat/completions`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: modelId,
          messages: [
            {
              role: "user",
              content: message,
            },
          ],
        }),
      });

      if (!response.ok) {
        throw new Error(`API request failed with status ${response.status}`);
      }

      const data = await response.json();
      return data.choices && data.choices[0] && data.choices[0].message
        ? data.choices[0].message.content
        : null;
    } catch (error) {
      console.error("API request error:", error);
      throw error;
    }
  }

  function addMessageToChat(role, content) {
    const messageDiv = document.createElement("div");
    messageDiv.className = `message ${role}`;

    const contentDiv = document.createElement("div");
    contentDiv.className = "message-content";
    contentDiv.textContent = content;

    messageDiv.appendChild(contentDiv);
    chatMessages.appendChild(messageDiv);

    // Scroll to bottom
    chatMessages.scrollTop = chatMessages.scrollHeight;
  }

  function addLoadingIndicator() {
    const loadingDiv = document.createElement("div");
    loadingDiv.className = "message system loading";

    const loadingContent = document.createElement("div");
    loadingContent.className = "message-content";

    const dots = document.createElement("div");
    dots.className = "loading-dots";

    for (let i = 0; i < 3; i++) {
      const dot = document.createElement("span");
      dots.appendChild(dot);
    }

    loadingContent.appendChild(dots);
    loadingDiv.appendChild(loadingContent);
    chatMessages.appendChild(loadingDiv);

    // Scroll to bottom
    chatMessages.scrollTop = chatMessages.scrollHeight;

    return loadingDiv;
  }

  function showError(container, message) {
    // Remove any existing error messages
    const existingError = container.querySelector(".error");
    if (existingError) {
      existingError.remove();
    }

    // Create and add new error message
    const errorDiv = document.createElement("div");
    errorDiv.className = "error";
    errorDiv.textContent = message;
    container.appendChild(errorDiv);
  }
});
