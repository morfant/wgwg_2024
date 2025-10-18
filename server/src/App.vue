<template>
  <div id="app" class="app-container">
    <!-- 왼쪽 텍스트 영역 -->
    <div class="chat-section">
      <h1>{{ activeMenu }}</h1>
      <div class="chat-box">
        <div
          v-for="(message, index) in messages"
          :key="index"
          :class="['message', message.agentType]" >
          <div v-html="renderMessage(message.text)"></div>
        </div>
        <div v-if="isFetching" class="loading-indicator">응답을 받아오는 중입니다...</div>
      </div>
      <div class="input-container">
        <input
          v-model="userInput"
          @keyup.enter="sendButtonClick"
          placeholder="Type a message..."
          class="input-box"
          :disabled="isFetching || !isConnected"
        />
        <button 
          @click="sendButtonClick" 
          class="send-button"
          :disabled="isFetching || !isConnected"
        >
          {{ isFetching ? "......" : "Send" }}
        </button>
      </div>
    </div>
    
    <!-- 오른쪽 영역: 토글 버튼 및 슬라이더 -->
    <div class="control-section">

      <!-- 1번 그룹 -->
      <div class="group" v-for="n in 5" :key="n">
        <button 
          class="big-btn" 
          :class="{ active: isActive(n) }" 
          @click="selectGroup(n)">
          {{ n }}
        </button>
        <div class="button-row">
          <button 
            v-for="(btn, index) in 5" 
            :key="index" 
            :class="['toggle-btn', { active: isActiveButton(n, index) }]"
            @click="toggleButtonInGroup(n, index)">
            {{ index + 1 }}
          </button>
        </div>
        <!--<label :for="'slider-' + n" class="slider-label">Tempo {{ n }}</label>-->
        <vue-slider 
          v-model="tempo[n - 1]" 
          :min="0" 
          :max="100" 
          :id="'slider-' + n"
          @change="handleSliderChange(n, 1, tempo[n - 1])" />

        <!--<label :for="'slider-' + n" class="slider-label">Volume {{ n }}</label>-->
        <vue-slider 
          v-model="volume[n - 1]" 
          :min="0" 
          :max="100" 
          :id="'slider-' + n"
          @change="handleSliderChange(n, 2, volume[n - 1])" />
      </div>

      <div class="slider-container">
        <!-- <h3>Control Sliders</h3> -->
        <div v-for="(knob, index) in con_knobs" :key="index + 5 + 5" style="margin-bottom: 20px;">
        <!-- <label :for="'slider-' + (index + 5 + 5)">
          {{ knob.label }}
        </label> -->
        <vue-slider
          :id="'slider-' + (index + 5 + 5)"
          v-model="knob.value"
          :min="0"
          :max="100"
          @change="handleSliderChange(0, index + 5 + 5, knob.value)"
        />
      </div>

      </div>
    </div>
  </div>
</template>

<script>
import { marked } from "marked";
import VueSlider from 'vue-slider-component'; // 슬라이더 컴포넌트 가져오기
import 'vue-slider-component/theme/default.css'; // 테마 스타일 추가

export default {
  components: {
    VueSlider, // 슬라이더 컴포넌트 등록
  },
  data() {
    return {
      userInput: "",
      messages: [], // 계속 누적되는 대화 기록
      isFetching: false,
      isConnected: false,
      socket: null,
      activeMenu: "WGWG ㅇㄱㅇㄱ", // 기본 메뉴 제목
      con_knobs: [
        { value: 20, label: "Reverb" },
        // { value: 20, label: "Duration" },
      ], // 슬라이더 6개

      buttons: Array(25).fill(false).map((_, i) => i % 5 === 0),
      selectedGroup: 1, // 현재 선택된 그룹 (1 ~ 5)
      tempo: Array(5).fill(50), // 각 그룹별 tempo 값 초기화
      volume: Array(5).fill(50), // 각 그룹별 volume 값 초기화

    };
  },
  methods: {
      toggleButtonInGroup(group, index) {
      const start = (group - 1) * 5; // 그룹의 첫 번째 버튼 인덱스
      const end = start + 5;         // 그룹의 마지막 버튼 인덱스

      // 같은 그룹의 모든 버튼을 비활성화
      for (let i = start; i < end; i++) {
        this.buttons[i] = false;
      }

      // 클릭한 버튼만 활성화
      this.buttons[start + index] = true;

      console.log(`Group ${group}, Button ${index + 1} toggled: ${this.buttons[start + index]}`);

      // 버튼에 대한 동작 정의 (WebSocket 전송)
      if (this.socket && this.socket.readyState === WebSocket.OPEN) {

        // For Test in local
        // if (group === 1) {
        //   this.socket.send(
        //     JSON.stringify({
        //       type: "Test",
        //       group: group,
        //       index: index + 1,
        //       value: this.buttons[start + index],
        //     })
        //   );
        // } else {
          this.socket.send(
            JSON.stringify({
              type: "Button",
              group: group,
              index: index + 1,
              value: this.buttons[start + index],
            })
          );
        // }

      }
    },

    // 현재 그룹에서 어떤 버튼이 활성화 상태인지 확인하는 메서드
    isActiveButton(group, index) {
      const start = (group - 1) * 5;
      return this.buttons[start + index];
    },

    selectGroup(group) {
      this.selectedGroup = group;
    },
    isActive(group) {
      return this.selectedGroup === group;
    },
    getButtonsForGroup(group) {
      const start = (group - 1) * 5;
      return this.buttons.slice(start, start + 5);
    },
    handleSliderChange(group, index, val) {
      // 슬라이더 값 변경에 대한 동작 정의
      console.log(`Group ${group}, Slider ${index} changed to ${val}`);
      if (this.socket && this.socket.readyState === WebSocket.OPEN) {
        this.socket.send(JSON.stringify({ type: "Slider", group: group, index: index, value: val}));
      }
    },
    sendButtonClick() {
      if (!this.isFetching) {
        this.sendMessage();
      }
    },
    sendMessage() {
      console.log("sendMessage()");

      // 메시지 전송 로직
      if (this.userInput.trim() === "") return;
      this.messages.push({
        sender: "User",
        text: this.userInput,
        agentType: "User",
      });
      this.isFetching = true; // 메시지 전송 시 로딩 상태 설정
      this.socket.send(JSON.stringify({ message: this.userInput}));
      this.userInput = "";
      this.updateScroll(); // 메시지 전송 후 스크롤
    },
    renderMessage(text) {
      return marked.parse(text);
    },
    updateScroll() {

      const chatBox = this.$el.querySelector('.chat-box');
      if (chatBox) {
      chatBox.scrollTop = chatBox.scrollHeight;
      }
      // 브라우저 창 전체를 스크롤하여 페이지의 맨 아래로 이동
      //window.scrollTo(0, document.body.scrollHeight);
    },
  },
  mounted() {
    // Vue 인스턴스를 전역 객체에 노출
    // 브라우저 콘솔에서 app.isConnected 등으로 접근이 가능해짐
    window.app = this;

    // 컴포넌트가 마운트될 때 웹소켓 연결 설정
    this.socket = new WebSocket('ws://localhost:4001/ws/chat');
    // this.socket = new WebSocket('ws://unbarrier.net:4001/ws/chat');

    this.socket.onopen = () => {
      console.log("WebSocket connection opened");
      this.isConnected = true; // 연결 성공 시 입력 활성화

      // heart beat
      // 30초마다 ping 메시지 전송
      this.pingInterval = setInterval(() => {
        if (this.socket.readyState === WebSocket.OPEN) {
            this.socket.send(JSON.stringify({ heartbeat : "ping" }));
            console.log("ping");
        }
      }, 30000); // 30초
    };

    this.socket.onmessage = (event) => {
      const data = JSON.parse(event.data);
      // console.log("서버 메시지 수신:", data);

      if (data.type) {
        const { type, group, index, value } = data;
        if (type === "Button") {
          console.log(`Button Event: Group ${group}, Index ${index}, Value ${value}`);

          // 버튼 상태 업데이트 (버튼 배열에서 해당 인덱스의 값을 설정)
          const start = (group - 1) * 5;
          this.buttons.fill(false, start, start + 5); // 해당 그룹의 버튼들 초기화
          this.buttons[start + index - 1] = value;    // 특정 버튼 활성화
        }

        if (type === "Slider") {
          console.log(`Slider Event: Group ${group}, Slider ${index}, Value ${value}`);

          if (index == 1) {
            // 그룹별 Tempo 슬라이더 갱신
            this.tempo.splice(group - 1, 1, value);  // tempo 배열의 값 변경
          } else if (index == 2) {
            // 그룹별 Volume 슬라이더 갱신
            this.volume.splice(group - 1, 1, value); // volume 배열의 값 변경
          } else {
            // 컨트롤 슬라이더 갱신 (con_knobs)
            const knobIndex = index - 10;
            this.con_knobs[knobIndex].value = value; // con_knobs의 객체 값 변경
          }
        }
      } else if (data.agentType) {
        const { agentType, response } = data;
        console.log("agentType: ", agentType)
        console.log(this.messages)
        if (data.response === "[END]") {
          this.isFetching = false;
        } else {
          if (
            this.messages.length > 0 &&
            this.messages[this.messages.length - 1].sender === "Bot" &&
            this.messages[this.messages.length - 1].agentType === agentType
          ) {
            // msg block에 내용 업데이트
            console.log("Updating...")
            const lastMessage = this.messages[this.messages.length - 1];
            lastMessage.text = response;
          } else {
            // msg block 새로 만듦
            console.log("New block...")
            this.messages.push({ sender: "Bot", text: response, agentType: agentType });
          }
          this.updateScroll(); // 메시지가 추가될 때마다 스크롤
        }
      } else {
        console.warn("Unknown message format:", data);
      }
    };

    this.socket.onerror = (error) => {
      console.error('WebSocket 오류:', error);
      this.isConnected = false; // 연결 종료 시 입력 비활성화
      this.isFetching = false;
      // ping 메시지 전송 중지
      clearInterval(this.pingInterval);
    };

    this.socket.onclose = () => {
      console.log('WebSocket 연결 종료');
      this.isConnected = false; // 연결 종료 시 입력 비활성화
      this.isFetching = false;
      // ping 메시지 전송 중지
      clearInterval(this.pingInterval);
    };
  },
};
</script>

<style src="./App.css"></style>