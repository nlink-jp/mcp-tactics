# mcp-tactics

[nlink-jp](https://github.com/nlink-jp) の 25 MCP サーバと 2 プロキシを横断する
戦術書 Skill（[ADR-003](https://github.com/nlink-jp/.github/blob/main/adr/003-mcp-tactics-skill.md)、
[ADR-018](https://github.com/nlink-jp/.github/blob/main/adr/018-mcp-observability-tiers.md)
と [ADR-027](https://github.com/nlink-jp/.github/blob/main/adr/027-mcp-tactics-scope-and-bundled-skills.md)
で改訂）。この数は「nlink-jp が出している MCP サーバのすべて」ではありません。
載せるのは、選び方や呼ぶ順序によって、調査が誰に見えるか・調査の材料がどこへ出るかが
変わるサーバです。手元で成果物を作るだけのサーバ（ナレーション、動画、画像生成、
レポートの組版）は対象外で、それぞれが自分の使い方を案内します。`SKILL.md` は意思決定テーブルのルーター — 入力アーティファクト→ルート、
サーバ横断チェーン、そして「その照会を誰が観測できるか」で序列化した 4 段の
エスカレーション・ドクトリン（外部観測者なし → サードパーティ照会 →
urlscan 経由の対象接触 → 自社 IP からの対象接触）— で、ドメイン別プレイブックを
`references/` に持ちます。記録するのは選択と順序のみで、パラメータとエラー回復は
各サーバの `get_usage` ツールが正典です。

## インストール

[Releases](https://github.com/nlink-jp/mcp-tactics/releases) から
`mcp-tactics-vX.Y.Z.zip` をダウンロードし、登録する:

- **アプリから**（Claude Desktop / claude.ai / モバイル）— スキル設定
  （カスタマイズ → スキル）で zip を追加する。**この経路を推奨**。
  スキルの保存場所が変わっても影響を受けない。
- **Claude Code** — `unzip mcp-tactics-vX.Y.Z.zip -d ~/.claude/skills/`。
  プロジェクト単位なら、プロジェクト内の `.claude/skills/` に展開する。

チェックアウトから:

```bash
make install
```

リリース zip をビルドして**それを**展開するので、手元で動かすものと
リリースが配るものが一致する。パッケージングの欠陥は利用者に届く前に
手元のインストールを壊す。`make install DEST=/path/to/skills` で別の場所へ、
`make uninstall` で削除。

## 使い方

これはリファレンス型の Skill です。組織の MCP サーバが関わるタスクでは
Claude が自律的に読み込み、`/mcp-tactics` で明示的に表示することもできます。

## 開発

```bash
make check     # 構造検証（frontmatter・相対リンク）＋ fleet 検査
make package   # dist/mcp-tactics-vX.Y.Z.zip を生成（zip ルート = スキルフォルダ）
```

スキル本体は [`mcp-tactics/`](mcp-tactics/) にあります。このディレクトリだけが
`make package` の配布物・`make install` のコピー対象で、リポジトリの
scaffolding（README・Makefile・tests）は配布物に含まれません。

サーバの追加・削除・ツールの増減時は意思決定テーブルと該当プレイブックを
更新します。ツールの引数が変わっただけなら何もしません — パラメータは
`get_usage` の責務です（ADR-003）。fleet の正本は `SKILL.md` のサーバ索引です。
`SKILL.md`・両 README・`AGENTS.md` に書かれたサーバ数が索引と食い違うとき、
または索引のサーバに対応するプレイブックが references 表に無いとき、
`make check` は失敗します。

## 履歴

v0.1.0 以前、このスキルは
[skills-series](https://github.com/nlink-jp/skills-series) に含まれていました。
分割の経緯は
[ADR-004](https://github.com/nlink-jp/.github/blob/main/adr/004-skills-series-umbrella.md)
を参照してください。

## ドキュメント

- [English](README.md)
- [日本語](README.ja.md)

## ライセンス

[MIT](LICENSE)
