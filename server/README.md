# dance-tech-web

## 프론트엔드
### Project setup
```
yarn install
```

### Compiles and hot-reloads for development(Test를 위해서는 여기까지만 하면 됩니다)
```
yarn serve 
```

### Compiles and minifies for production
```
yarn build
```

### Lints and fixes files
```
yarn lint
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).


## 백엔드(Python 3.11.7로 진행, 가상환경 설정 권장)

### setup!
```
cd backend
pip install -r requirements.txt
```

### Run server
```
uvicorn main:app --reload
```


## pm2를 이용한 프로세스 관리
```
pm2 list // pm2를 통해 실행중인 프로세스 확인

pm2 logs <name> // name에 해당하는 프로세스의 로그 확인 (name은 pm2 list를 통해 확인 가능)

pm2 restart all // pm2가 관리하는 모든 프로세스 재시작

pm2 delete <name> // 특정 프로세스 삭제(정지)

pm2 start yarn --name "front" -- serve // web server 실행

// backend 폴더로 이동한 후에
Pm2 start ecosystem.config.js // backend 실행
```
