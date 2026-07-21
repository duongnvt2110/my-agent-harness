#!/usr/bin/env python3
import argparse
import html
import pathlib


def render_markdown(text: str) -> str:
    lines = []
    for raw in text.splitlines():
        line = raw.strip()
        if not line:
            continue
        if line.startswith("# "):
            lines.append(f"<h1>{html.escape(line[2:])}</h1>")
        elif line.startswith("## "):
            lines.append(f"<h2>{html.escape(line[3:])}</h2>")
        else:
            lines.append(f"<p>{html.escape(line)}</p>")
    return "\n".join(lines)


def build(content_dir: pathlib.Path, output_dir: pathlib.Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    links = []
    for post in sorted(content_dir.glob("*.md")):
        title = post.stem.replace("-", " ").title()
        body = render_markdown(post.read_text())
        target = output_dir / f"{post.stem}.html"
        target.write_text(f"<!doctype html>\n<title>{html.escape(title)}</title>\n{body}\n")
        links.append((title, target.name))
    index = "\n".join(f'<li><a href="{href}">{html.escape(title)}</a></li>' for title, href in links)
    (output_dir / "index.html").write_text(f"<!doctype html>\n<h1>Posts</h1>\n<ul>\n{index}\n</ul>\n")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--content", default="content")
    parser.add_argument("--output", default="public")
    args = parser.parse_args()
    build(pathlib.Path(args.content), pathlib.Path(args.output))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
