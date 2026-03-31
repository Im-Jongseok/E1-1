# AI/SW 개발 워크스페이스 구축

## 프로젝트 개요

* Docker를 활용해 재현 가능한 실행 환경 구성
* CLI 환경에 익숙해지기
* Git/GitHub으로 소스코드 관리 및 협업 준비

### 프로젝트 디렉토리 구조 설계 기준

프로젝트 디렉토리 구조는 다음과 같은 기준으로 구성되었습니다:
- **app/**: 웹 애플리케이션 소스 코드 및 정적 파일 저장
- **res/**: 스크린샷, 이미지 등의 리소스 파일 저장 (문서화용)
- **workstation/**: 호스트-컨테이너 간 바인드 마운트 실습용 디렉토리
- **Dockerfile**: Docker 이미지 빌드 설정
- **README.md**: 프로젝트 설명 및 실습 가이드

이 구조는 실습 목적에 따라 기능별로 분리하여 재현성과 유지보수성을 높였습니다.

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

### 포트/볼륨 설정 재현 가능성

포트와 볼륨 설정을 재현 가능하게 정리하기 위해:
- **명령어 표준화**: 모든 docker run 명령어에 -p(포트)와 -v(볼륨) 옵션을 명시적으로 포함
- **스크립트화**: 자주 사용하는 설정을 shell script로 저장하여 반복 실행 가능
- **문서화**: 각 옵션의 목적과 예시를 README에 기록하여 팀 공유
- **환경 변수 활용**: 포트 번호 등을 변수화하여 설정 변경 시 쉽게 수정


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

### 이미지와 컨테이너의 차이 (빌드/실행/변경 관점)

- **빌드 관점**: 이미지는 Dockerfile로부터 빌드되어 불변의 템플릿 역할을 합니다. 컨테이너는 이미지의 인스턴스로, 실행 시 생성
- **실행 관점**: 이미지는 실행되지 않으며, 컨테이너가 실제로 실행되어 프로세스를 호스팅.
- **변경 관점**: 이미지는 읽기 전용으로 변경할 수 없으며, 컨테이너는 실행 중 파일 시스템 변경이 가능하지만 컨테이너 삭제 시 사라wla

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

### 컨테이너 내부 포트 직접 접속 불가 이유 및 필요성

컨테이너 내부 포트(예: 80)로 직접 접속할 수 없는 이유는 컨테이너가 격리된 네트워크 환경에서 실행되기 때문.
호스트와 컨테이너 간 네트워크가 분리되어 있어, 호스트에서 컨테이너의 내부 포트에 직접 접근 불가.

포트 매핑(-p 옵션)이 필요한 이유는 호스트의 포트(예: 8081)를 컨테이너의 포트(80)에 연결하여 외부에서 컨테이너의 서비스에 접근할 수 있도록 하기 위함.
이를 통해 웹 서버 등의 애플리케이션을 호스트 브라우저에서 테스트 가능.

### 호스트 포트 충돌 시 진단 순서

"호스트 포트가 이미 사용 중"이라 포트 매핑이 실패할 경우 진단 순서:
1. **포트 사용 확인**: `lsof -i :포트번호` 또는 `netstat -tulpn | grep :포트번호`로 어떤 프로세스가 포트를 사용 중인지 확인
2. **Docker 컨테이너 확인**: `docker ps`로 다른 컨테이너가 해당 포트를 사용 중인지 확인
3. **프로세스 종료**: 필요 시 `kill PID`로 충돌하는 프로세스 종료
4. **대안 포트 사용**: 다른 호스트 포트(예: 8082)로 매핑하여 재시도
5. **방화벽/보안 설정 확인**: 방화벽이 포트를 차단하는지 확인

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

### 컨테이너 삭제 후 데이터 유실 방지 대안

컨테이너 삭제 시 내부 파일 시스템의 데이터가 사라지는 경험을 방지하기 위한 대안:
1. **Docker 볼륨 사용**: `docker volume create`로 영속 볼륨을 생성하고 `-v` 옵션으로 연결. 컨테이너 재생성 시 데이터 유지.
2. **바인드 마운트**: 호스트 디렉토리를 `-v`로 마운트하여 호스트에 데이터 저장.
3. **데이터베이스 컨테이너**: 별도 데이터베이스 컨테이너를 사용하여 애플리케이션과 데이터 분리.

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

### 상대경로
내가 있는 위치( . ) 기준으로 표현하는 주소
### 절대 경로
루트( / ) 부터 시작하는 전체 주소

### 절대 경로/상대 경로 선택 기준

- **상대 경로 선택 상황**: 현재 디렉토리 내에서 작업할 때, 스크립트나 설정 파일에서 유연성을 위해 사용. 예: `./app` (현재 위치의 app 폴더)
- **절대 경로 선택 상황**: 스크립트가 어디서 실행되든 일관된 경로를 보장해야 할 때, 또는 다른 사용자와 공유 시. 예: `/Users/username/project/app` (항상 같은 위치)

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

### 파일 권한 숫자 표기 규칙 (Octal mode)

파일 권한은 8진수로 표기되며, 각 숫자는 rwx(읽기/쓰기/실행) 권한의 조합을 나타냄:
- 4: 읽기 (r)
- 2: 쓰기 (w)  
- 1: 실행 (x)
- 0: 권한 없음

예를 들어 755는:
- 소유자(7): rwx (4+2+1)
- 그룹(5): r-x (4+0+1)
- 기타(5): r-x (4+0+1)

권한은 보안과 기능 요구사항에 따라 결정되며, 실행 파일은 755, 설정 파일은 644 등으로 설정.

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

## Trouble Shooting

### Trouble Shooting1

#### 처음 만난 ERROR
```zsh
docker rm ws1
```
Error response from daemon: cannot remove container "ws1": container is running: stop the container before removing or force remove

-> 현재 실행중이라 삭제 불가능 에러 발생

```zsh
# 방법1
docker rm --force ws1

# 방법2
docker stop ws1
docker rm ws1
```
-> Error를 읽고 안내하는 방법으로 문제 해결

### Trouble Shooting2
#### Dockerfile 생성중 만난 문제

``` dockerfile
COPY app/ /usr/share/nginx/html
COPY app /usr/share/nginx/html
```
-> 해당 코드의 차이를 구분하지 못했음

```Dockerfile
COPY app/ /usr/share/nginx/html/ # app 폴더 안의 내용물 → html/ 안으로 복사 
COPY app /usr/share/nginx/html/ # app 폴더 자체 → html/app/ 으로 복사

#결과 비교
COPY app/ → /usr/share/nginx/html/index.html 
COPY app → /usr/share/nginx/html/app/index.html
```
-> app 폴더 자체를 copy
-> app/ 폴더 내부를 copy

```Dockerfile
WORKDIR [filename]
```
-> 해당 코드의 의미를 알지 못함

```Dockerfile
WORKDIR /app
```
-> 해당 코드의 의미를 알지 못함

* exec로 bash 접근시 현재 위치가 작업 폴더에 자동으로 위치
* RUN으로 파일 생성 명령어를 작성시 작업폴더에 생성
