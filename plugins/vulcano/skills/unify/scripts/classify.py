#!/usr/bin/env python3
import json,re,sys
CODE=re.compile(r"\b(arregla|refactor|diff|stacktrace|compile|typecheck|neon|deploy|bug|hotfix|archivo|modulo|codigo|typescript|sql)\b",re.I)
REASON=re.compile(r"\b(por qu|tradeoff|arquitectura|decision|spec)\b",re.I)
RESEARCH=re.compile(r"\b(busca|competencia|nuevo|benchmark|investiga)\b",re.I)
MEDIA=re.compile(r"\b(imagen|video|higgsfield|thumbnail)\b",re.I)
SWARM=re.compile(r"\b(enjambre|paralelo|multi-paso|orquesta|complex)\b",re.I)
HIGH=re.compile(r"\b(ahora|urgente|se cayo|demo hoy)\b",re.I)
CHAIN={"code":["claude_A","codex","grok"],"reason":["claude_A","grok"],"debug":["claude_A","grok"],"chat":["grok"],"fast":["grok"],"research":["grok"],"media":["higgsfield"],"swarm":["enjambre"],"complex":["enjambre"]}
def classify(t):
    t=t or ""
    kind="swarm" if SWARM.search(t) else "media" if MEDIA.search(t) else "code" if CODE.search(t) else "research" if RESEARCH.search(t) else "reason" if REASON.search(t) else "chat"
    return {"task_type":kind,"urgency":"high" if HIGH.search(t) else "normal","chain":CHAIN[kind],"first":CHAIN[kind][0],"dispatch_alias":"claude" if kind in {"code","reason","debug"} else kind}
if __name__=="__main__":
    print(json.dumps(classify(" ".join(sys.argv[1:]) or sys.stdin.read()),ensure_ascii=False))
