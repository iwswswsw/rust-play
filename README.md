# rust-play

RustでAPIを作ってみる

## 前提条件

以下のインストールを前提とする。  

- Docker
- Docker Compose
- direnv

※AWS Cloud9で動作確認済み

## 開発環境セットアップ

### Linux(AWS Cloud9)

#### Docker-Composeのインストール

以下サイトで最新バージョンを確認
https://docs.docker.com/compose/install/
```bash
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
$ docker-compose -v
```

#### direnvのインストール

以下サイトで最新バージョンを確認
https://github.com/direnv/direnv/releases
```bash
$ wget -O direnv https://github.com/direnv/direnv/releases/download/v2.6.0/direnv.linux-amd64
$ chmod +x direnv
$ sudo mv direnv /usr/local/bin/

$ echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
$ source ~/.bashrc
```

### セットアップ

1. `setup.sh`を実行する
    ```bash
    $ ./docker/dev/scripts/setup.sh
    ```

## 使い方

以下コマンドでAPIを起動する
```bash
$ docker-compose up api-rust
```

ブラウザで「http://{ホストのIPアドレス}:8080」にアクセスすることでAPIを叩ける

## 開発方法

### DB起動

```bash
$ docker-compose up -d db
```

### psqlしたいとき

```bash
$ docker-compose run --rm pg
```

### ビルド実行

```bash
$ docker-compose run --rm api-rust-cmd cargo build
```
or
```bash
$ docker-compose run --rm api-rust-cmd
$ cargo build
```

## 開発オプション

### docker-composeエイリアス設定

1. ホームディレクトリに以下内容の`.aliases`ファイルを作成する。
    ```
    # docker compose
    alias dc="docker-compose"
    alias dcr="docker-compose run --rm"
    alias dcrs="docker-compose run --rm --service-ports"
    alias dcu="docker-compose up"
    ```

1. ホームディレクトリの`.bashrc`に以下を追記する。
    ```
    # get aliases
    if [ -f ~/.aliases ]; then
      source ~/.aliases
    fi
    ```

1. ターミナルを再起動する。

1. 以下のように`.aliases`内のエイリアスが利用できる。
    ```bash
    $ dcu api-rust
    ```