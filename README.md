# AI/SW 개발 워크스페이스 구축

## 프로젝트 개요

* Docker를 활용해 재현 가능한 실행 환경 구성
* CLI 환경에 익숙해지기
* Git/GitHub으로 소스코드 관리 및 협업 준비

---
## 실행 환경

| 항목     | 내용               |
| ------ | ---------------- |
| OS     | macOS Tahoe 26.2 |
| Shell  | zsh              |
| Docker | 29.3.1           |
| Git    | 2.53.0           |

---
## 수행 항목 체크리스트

1. Docker
	- [x] 도구 설치 및 확인 
	- [x] 이미지 다운로드/ 제거 및 확인
	- [x] 커스텀 이미지 제작
	- [x] 컨테이너 생성/ 삭제 및 확인
	- [x] 포트 매핑 접속 확인
	- [x] 바인드 마운트 반영
	- [x] 볼륨 영속성
	- [x] 로그/ 리소스 확인
	
2. Terminal
	- [x] 터미널 조작
	- [x] 권한 실습
	
3. Git
	- [x] GitHub 가입/ 로그인
	- [x] 도구 설치 및 확인
	- [x] Git 세팅
	- [x] GitHub 연동
	- [x] repo 생성
	- [x] commit/ push
	- [x] VSCode 설치 및 GitHub 연동

---
## Docker
https://docs.docker.com/reference/cli/docker/

#### 설치 확인
```zsh
# docker install
brew install docker
docker --version
docker info
```

![Docker 설치 확인](./res/스크린샷%202026-03-31%20오후%2012.10.15.png)
![Docker 설치 확인](./res/스크린샷%202026-03-31%20오후%2012.11.04.png)

#### Docker 이미지 관리
```zsh 
# docker IMAGE
# download
docker pull IMAGE
# remove
docker rmi IMAGE
# ls
docker images
```

#### Hello-world
```zsh
 docker pull hello-world
 docker run -it hello-world
```

![Hello-world 실행](./res/스크린샷%202026-03-31%20오후%202.20.28.png)
-> $ docker run -it ubuntu bash 
![Ubuntu bash 진입](./res/스크린샷%202026-03-31%20오후%203.33.44.png)
진입 성공 !
#### 옵션 A: Dockerfile 만들기
```dockerfile
FROM nginx:alpine

LABEL org.opencontainers.image.title="my-custom-nginx"
LABEL maintainer="Im-Jongseok"
LABEL description="NGINX 실습 이미지"

ENV APP_ENV=dev PORT=80 APP_NAME=ws

ARG BUILD_VERSION=1.0

LABEL version="${BUILD_VERSION}"

WORKDIR /usr/share/nginx/html

COPY app/ /usr/share/nginx/html

EXPOSE 80

RUN apk update && \
apk add --no-cache curl vim bash && \
rm -rf /var/cache/apk/*

HEALTHCHECK --interval=30s --timeout=5s --retries=3\
CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
```

#### 빌드
```zsh
docker build -t my-custom-nginx:1.0 .
```
![Docker 빌드](./res/스크린샷%202026-03-31%20오후%204.14.53.png)

### 컨테이너 만들기

```zsh
# docker container
# create
docker run [OPTION] IMAGE
# delete
docker rm CONTAINER
# ls
docker ps
docker ps -a
# docker CLI
docker exec [OPTION] CONTAINER COMMAND
```

```zsh
# container 생성
docker run --name my-custom-container my-custom-nginx:1.0 
```
![컨테이너 생성](./res/스크린샷%202026-03-31%20오후%203.41.11.png)

### 컨테이너 포트 매핑

```zsh
# 현재 포트 host:8080 -> client:80
docker run --name my-nginx-container -p 8081:80 my-custom-nginx:1.0

```
![포트 매핑 실행](./res/스크린샷%202026-03-31%20오후%203.47.13.png)
![포트 매핑 결과](./res/스크린샷%202026-03-31%20오후%203.48.01.png)
-> http://localhost:8081/ 접속 성공!

### 바인드 마운트
-> 호스트 폴더를 컨테이너에 연결

```zsh
docker run -d -p 8082:80 -v ./workstation/app:/usr/share/nginx/html \
  --name bind-test my-custom-nginx:1.0
```

![바인드 마운트 실행](./res/스크린샷%202026-03-31%20오후%204.26.08.png)
![바인드 마운트 결과](./res/스크린샷%202026-03-31%20오후%204.38.04.png)
-> 호스트에서 수정시 실행 중인 컨테이너에 적용!
### 불륨 영속성
-> 컨테이너 내부 데이터 유실 위험 방지
```zsh
# 볼륨 생성
docker volume create mydata

# 컨테이너에 볼륨 연결 후 데이터 작성
docker run -d --name vol-test -v mydata:/data my-custom-nginx:1.1
docker exec -it vol-test /bin/bash

# 영속 데이터
echo '2026-3-31' > /data/today.txt


# 컨테이너 삭제
docker rm -f vol-test

# 새 컨테이너에서 데이터 확인
docker run -d --name vol-test2 -v mydata:/data my-custom-nginx:1.1

cat /data/today.txt
-> "2026-3-31"


# 볼륨 조회/ 삭제
docker volume ls
docker volume rm mydata

# 특정 볼륨 상세 정보
docker volume inspect mydata
```

![불륨 영속성 확인](./res/스크린샷%202026-03-31%20오후%204.51.14.png)

### 로그 & 리소스 확인

``` zsh
# 로그 확인
docker logs [OPTION] CONTAINER

# 상태 확인
docker stats
```

![로그 및 리소스 확인](./res/스크린샷%202026-03-31%20오후%205.04.49.png)
-> 실행중인 컨테이너 상세 정보 출력

#  터미널 조작 로그 기록
	다음 작업을 터미널로 수행하고, 명령어 + 출력 결과를 기술 문서에 기록한다.
    - 현재 위치 확인, 목록 확인(숨김 파일 포함), 이동, 생성, 복사, 이동/이름변경, 삭제
    - 파일 내용 확인, 빈 파일 생성
### 상대경로
내가 있는 위치( . ) 기준으로 표현하는 주소
### 절대 경로
루트( / ) 부터 시작하는 전체 주소

* **현재 위치 확인**
	$ pwd
	![현재 위치 확인](./res/스크린샷%202026-03-30%20오후%205.31.33.png)

* **목록 확인 (숨김 파일 포함)**
	$ ls -l
	$ ls -al
	![목록 확인](./res/스크린샷%202026-03-30%20오후%205.32.15.png)

* **이동**
	$ cd "파일 경로"
	$ cd .. -> 상위 경로
	$ cd ~ -> home
	![경로 이동](./res/스크린샷%202026-03-30%20오후%206.11.47.png)

* **생성**
	$ mkdir "폴더 이름"
	$ mkdir -p "상위경로"/"하위경로" -> 둘다 생성
	$ echo "content" > "파일 명"
	![폴더 생성](./res/스크린샷%202026-03-30%20오후%205.42.33.png)

* **복사**
	$ cp "res" "dest"
	$ cp -r "res" "dest" -> 폴더 통채로 복사
	![파일 복사](./res/스크린샷%202026-03-30%20오후%205.45.47.png)

* **이동/ 이름변경**
	$ mv "res file" "dest folder" -> 이동
	$ mv "res file" "dest file" -> 이름 변경

	![파일 이동 및 이름 변경](./res/스크린샷%202026-03-30%20오후%205.54.37.png)

* **삭제**
	$ rm "파일 명"
	![이미지].(./res/스크린샷 2026-03-30 오후 5.55.00.png)
	$ rm -r "폴더 명"
	![파일 삭제](./res/스크린샷%202026-03-30%20오후%205.52.00.png)
	$ rm -rf "파일 명" -> 강제 삭제

* **파일 내용 확인**
	$ cat "파일 명"
	![파일 내용 확인](./res/스크린샷%202026-03-30%20오후%205.57.38.png)

* **빈 파일 생성**
	$ touch "파일 명"
	![빈 파일 생성](./res/스크린샷%202026-03-30%20오후%205.59.21.png)

###  권한 실습 및 증거 기록
	
	![권한 확인 1](./res/스크린샷%202026-03-30%20오후%206.22.07.png)
	![권한 확인 2](./res/스크린샷%202026-03-30%20오후%206.28.18.png)
	-> x 가 없어서 cd 실행 불가
	![권한 확인 3](./res/스크린샷%202026-03-30%20오후%206.35.26.png)
	-> w변경으로 생성 권한 제어
	![권한 확인 4](./res/스크린샷%202026-03-30%20오후%206.37.07.png)
	-> 파일 읽기 권한 변경

#  Git 설정 및 GitHub 연동

### Git 설치
	https://git-scm.com/install/mac
	$ brew install git

* **설치 확인**
	$ git --version

* **계정 설정**
	$ git config --global user.name "Im-Jongseok"
	$ git config --global user.email "im.jongseoklee@gmail.com"

* **설정 확인**
	$ git config --list
	![Git 설정 확인](./res/git%20config%20--list.png)

* **기본 브랜치 설정**
	$ git config --global init.defaultBranch main

### GitHub 설치
	$ brew install gh

* ***계정 로그인** 
	$ gh auth login

* **로그인 확인** 
	$ gh auth status
	![GitHub 로그인 확인](./res/gh%20auth%20status.png)
### CLI
* **원하는 폴더로 이동 및 생성**
	$ cd ~
	$ mkdir E1-1
	$ cd E1-1

* **git 초기화**
	$ git init
	![Git 초기화](./res/git%20init.png)

### repository 생성
	$ gh repo create E1-1 --public --source=. --remote=origin

* **README.md 생성**
	$ echo "# E1-1" > README.md

	$ git add .
	$ git commit -m "init: 첫 커밋"
	$ git log
	$ git push -u origin main

