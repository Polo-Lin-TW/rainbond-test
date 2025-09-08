<template>
  <div id="app">
    <header>
      <h1>Hello World App</h1>
      <p>FastAPI + Vue.js + SQLite</p>
    </header>

    <main>
      <div class="card">
        <h2>API Status</h2>
        <p v-if="apiStatus">{{ apiStatus }}</p>
        <button @click="checkHealth">Check API Health</button>
      </div>

      <div class="card">
        <h2>Send Message</h2>
        <div class="form-group">
          <input 
            v-model="newMessage" 
            type="text" 
            placeholder="Enter your message"
            @keyup.enter="sendMessage"
          />
          <button @click="sendMessage" :disabled="!newMessage.trim()">
            Send Message
          </button>
        </div>
      </div>

      <div class="card">
        <h2>Recent Messages</h2>
        <div v-if="messages.length === 0" class="no-messages">
          No messages yet. Send your first message!
        </div>
        <div v-else class="messages">
          <div 
            v-for="message in messages" 
            :key="message.id" 
            class="message"
          >
            <div class="message-content">{{ message.content }}</div>
            <div class="message-time">
              {{ formatDate(message.created_at) }}
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'App',
  data() {
    return {
      apiStatus: '',
      newMessage: '',
      messages: []
    }
  },
  async mounted() {
    await this.checkHealth()
    await this.loadMessages()
  },
  methods: {
    async checkHealth() {
      try {
        const response = await axios.get('/api/health')
        this.apiStatus = `✅ ${response.data.message}`
      } catch (error) {
        this.apiStatus = `❌ API connection failed: ${error.message}`
      }
    },
    async loadMessages() {
      try {
        const response = await axios.get('/api/messages')
        this.messages = response.data
      } catch (error) {
        console.error('Failed to load messages:', error)
      }
    },
    async sendMessage() {
      if (!this.newMessage.trim()) return
      
      try {
        await axios.post('/api/messages', {
          content: this.newMessage
        })
        this.newMessage = ''
        await this.loadMessages()
      } catch (error) {
        console.error('Failed to send message:', error)
        alert('Failed to send message. Please check the API connection.')
      }
    },
    formatDate(dateString) {
      const date = new Date(dateString)
      return date.toLocaleString()
    }
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Arial', sans-serif;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
}

#app {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
  color: white;
}

header {
  text-align: center;
  margin-bottom: 30px;
}

header h1 {
  font-size: 2.5rem;
  margin-bottom: 10px;
}

header p {
  font-size: 1.1rem;
  opacity: 0.9;
}

.card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 15px;
  padding: 25px;
  margin-bottom: 20px;
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
  border: 1px solid rgba(255, 255, 255, 0.18);
}

.card h2 {
  margin-bottom: 15px;
  font-size: 1.5rem;
}

.form-group {
  display: flex;
  gap: 10px;
  align-items: center;
}

input {
  flex: 1;
  padding: 12px 16px;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  background: rgba(255, 255, 255, 0.9);
  color: #333;
}

input:focus {
  outline: none;
  box-shadow: 0 0 0 2px rgba(255, 255, 255, 0.5);
}

button {
  padding: 12px 20px;
  background: rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 8px;
  color: white;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
}

button:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.no-messages {
  text-align: center;
  opacity: 0.7;
  font-style: italic;
  padding: 20px;
}

.messages {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.message {
  background: rgba(255, 255, 255, 0.1);
  padding: 15px;
  border-radius: 10px;
  border-left: 4px solid rgba(255, 255, 255, 0.5);
}

.message-content {
  font-size: 16px;
  margin-bottom: 5px;
}

.message-time {
  font-size: 12px;
  opacity: 0.7;
}

@media (max-width: 600px) {
  #app {
    padding: 10px;
  }
  
  .form-group {
    flex-direction: column;
  }
  
  input, button {
    width: 100%;
  }
}
</style>