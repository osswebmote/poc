import express from 'express';
import { WebSocketServer } from 'ws';
import path from 'path';

const app = express();
const __dirname = path.resolve();

// 서버 실행
const server = app.listen(3000, () => {
  console.log('server running at http://localhost:3000');
});

// 정적 파일 제공 (dist 폴더 내 파일)
app.use(express.static(path.join(__dirname, '/build_game')));

// 라우트 설정 (최종적으로 index.html 제공)
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'build_game', 'newGame.html'));
});

const wss = new WebSocketServer({ server });

let client_phone;
let client_computer;


// WebSocket 연결 이벤트 처리
wss.on('connection', (ws) => {
  let user = ws;
  // 클라이언트로부터 메시지를 받았을 때 실행되는 함수
  ws.on('message', (data) => {
    try {
      // 자이로스코프 데이터는 JSON 문자열로 전송되므로, 이를 파싱
      let parsedData = JSON.parse(data);
      if (parsedData.event == 'type_phone') {
        client_phone = user;
        alertconnect();
      }

      if (parsedData.event == 'type_computer') {
        client_computer = user;
        alertconnect();
      }
      
      if (parsedData.event === 'gyroscope_data') {
        if (client_computer) {
          client_computer.send(JSON.stringify(parsedData));
        }
      } 
      
    } catch (err) {
      console.log('Error parsing message:', err);
    }
  });

  // 클라이언트 연결 종료 이벤트 처리
  ws.on('close', () => {
    console.log('Client disconnected');
    if (ws == client_computer) {
      client_computer = null;
    } else if (ws == client_phone) {
      client_phone = null;
    }
  });
});

function alertconnect () {
  if (client_phone && client_computer) {
    let data = {
      event : "alertconnect",
    }
    client_computer.send(JSON.stringify(data));
  }
}