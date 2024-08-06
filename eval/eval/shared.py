import modal

app = modal.App(name="canary-eval")
image = modal.Image.debian_slim().pip_install("fastapi").pip_install("ragas")
