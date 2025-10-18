<template>
  <div id="app">
    <div class="sidebar">
      <h2>AI Collaborator</h2>
      <ul>
        <li 
          v-for="menu in menus" 
          :key="menu" 
          @click="setActiveMenu(menu)"
          :class="{ active: menu === activeMenu }"
        >
          {{ menu }}
        </li>
      </ul>
    </div>
    <div class="main-container">
      <div class="chat-container">
        <h1>{{ activeMenu }}</h1>
        <div class="chat-box">
          <div
            v-for="(message, index) in messages"
            :key="index"
            :class="['message', message.agentType]" >
            <div v-html="renderMessage(message.text)"></div>
            <button v-if="isReportEnd" @click="downloadPDF(index)" class="pdf-button">
              Download PDF
            </button>
          </div>
          <div v-if="isFetching" class="loading-indicator">응답을 받아오는 중입니다...</div>
        </div>
        <div class="input-container">
          <input
            v-model="userInput"
            @keyup.enter="handleButtonClick"
            placeholder="Type a message..."
            class="input-box"
            :disabled="isFetching || !isConnected"
          />
          <button 
            @click="handleButtonClick" 
            class="send-button"
            :disabled="isFetching || !isConnected"
          >
            {{ isFetching ? "......" : "Send" }}
          </button>
        </div>
      </div>
      
      <!-- 오른쪽 영역에 버튼과 슬라이더 추가 -->
      <div class="control-panel">
        <h2>Control Panel</h2>
        <div class="button-container">
          <button v-for="(btn, index) in buttons" :key="index" @click="handleButtonClick_sound(btn)">
            Button {{ index + 1 }}
          </button>
        </div>
        <div class="slider-container">
          <h3>Knob Controls</h3>
          <vue-slider
            v-for="(knob, index) in knobs"
            :key="index"
            v-model="knob.value"
            :min="0"
            :max="100"
            @change="handleKnobChange(index, knob.value)"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { marked } from "marked";
import html2pdf from 'html2pdf.js';
import VueSlider from 'vue-slider-component'; // 슬라이더 컴포넌트 가져오기
import 'vue-slider-component/theme/default.css'; // 테마 스타일 추가

export default {
  components: {
    VueSlider, // 슬라이더 컴포넌트 등록
  },
  data() {
    return {
      userInput: "",
      messages: [],
      isFetching: false,
      isReportEnd: false,
      isConnected: false, // 웹소켓 연결 상태
      socket: null,
      menus: ["Research", "Rehearsal", "Feedback", "Product"], // 메뉴 항목 추가
      activeMenu: "Research", // 기본 메뉴 설정
      buttons: [1, 2, 3, 4], // 버튼 4개 추가
      knobs: [
        { value: 50 },
        { value: 50 },
        { value: 50 },
        { value: 50 },
        { value: 50 },
        { value: 50 },
      ], // 슬라이더 6개 추가
    };
  },
  methods: {
    handleButtonClick_sound(btn) {
      console.log(`Button ${btn} clicked`);
      if (btn === 1 && this.socket && this.socket.readyState === WebSocket.OPEN) {
        // 웹소켓을 통해 but_1_on 메시지 전송
        // this.socket.send('but_1_on');
        this.socket.send(JSON.stringify({ message: 'but_1_on' }));
        console.log('but_1_on 메시지를 전송했습니다.');
      } else {
        console.error('웹소켓이 열려 있지 않거나 버튼 번호가 잘못되었습니다.');
      }
      // 버튼 클릭에 대한 동작 정의
    },
    handleKnobChange(index, value) {
      console.log(`Slider ${index + 1} changed to ${value}`);
      // 슬라이더 값 변경에 대한 동작 정의
    },
    handleButtonClick() {
      if (!this.isFetching) {
        this.sendMessage();
      }
    },
    connectWebSocket() {
      console.log("connectWebSocket()");
      // WebSocket 연결 설정
    },
    sendMessage() {
      console.log("sendMessage()");
      // 메시지 전송 로직
    },
    setActiveMenu(menu) {
      this.activeMenu = menu; // 선택된 메뉴 항목 설정
    },
    renderMessage(text) {
      return marked.parse(text);
    },
    updateScroll() {
      // 브라우저 창 전체를 스크롤하여 페이지의 맨 아래로 이동
      window.scrollTo(0, document.body.scrollHeight);
    },
    downloadPDF(index) {
      const message = this.messages[index];

      // Markdown 형식의 텍스트를 HTML로 변환
      const htmlContent = marked.parse(message.text);
      
      // 스타일을 적용하기 위한 HTML 구조 생성
      const content = `
        <div id="pdf-content" style="
          font-family: Arial, sans-serif;
          padding: 20px;
          color: #333;
          line-height: 1.5;
        ">
          ${htmlContent}
        </div>
      `;
      
      // 임시로 HTML 콘텐츠를 문서에 추가
      const div = document.createElement("div");
      div.innerHTML = content;
      document.body.appendChild(div);

      // html2pdf.js를 사용하여 PDF로 변환
      const element = document.getElementById('pdf-content');
      const options = {
        margin: [5, 10], // top/bottom, left/right
        filename: `message-${index + 1}.pdf`,
        html2canvas: { scale: 2 },
        jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
      };

      html2pdf().from(element).set(options).save().then(() => {
        // PDF 저장 후, 임시로 추가한 HTML 콘텐츠를 제거
        document.body.removeChild(div);
      });
    }
  },
  mounted() {
    this.connectWebSocket();

    // 컴포넌트가 마운트될 때 웹소켓 연결 설정
    this.socket = new WebSocket('ws://localhost:4001/ws/chat');

    this.socket.onopen = () => {
      console.log('WebSocket 연결됨');
    };

    this.socket.onmessage = (event) => {
      console.log('메시지 수신:', event.data);
    };

    this.socket.onerror = (error) => {
      console.error('WebSocket 오류:', error);
    };

    this.socket.onclose = () => {
      console.log('WebSocket 연결 종료');
    };
  },
};
</script>

<style src="./App.css"></style>