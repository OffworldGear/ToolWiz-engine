import sys, os, json, glob, collections, statistics
sys.path.insert(0, os.getcwd()); sys.path.insert(0, os.path.join(os.getcwd(), "tests"))
os.environ["TOOLWIZ_MODEL"] = "v2"
import test_vendor_conformance as C
import app
from concurrent.futures import ProcessPoolExecutor

def vmid(rows, key):
    vals = []
    for r in rows:
        c = r["cut"][key]
        v = c.get("nominal")
        if v is None and c.get("min") is not None and c.get("max") is not None: v = (c["min"] + c["max"]) / 2
        if v is None: v = c.get("max") or c.get("min")
        if v is not None: vals.append(v)
    return statistics.median(vals) if vals else None

if __name__ == "__main__":
    fams = set(app.physics.machinability)
    groups = collections.defaultdict(list)
    for path in sorted(glob.glob(os.path.join(C.BENCH_DIR, "*.json"))):
        vendor = os.path.basename(path)[:-5]
        for r in json.load(open(path))["rows"]:
            if C.in_scope(r, fams) and r["operation"] in ("hem", "rough", "side"):
                groups[(vendor,) + C.group_of(r)].append(r)
    keys = sorted(groups)
    with ProcessPoolExecutor(max_workers=8) as ex:
        outs = list(ex.map(C.run_job, [("engage", groups[k]) for k in keys], chunksize=4))
    res = []
    for k, o in zip(keys, outs):
        rows = groups[k]
        if "error" in o or not o.get("feasible"): 
            res.append(dict(vendor=k[0], family=k[1], op=k[2], band=k[3], eng=k[4], n=len(rows), ok=False)); continue
        s, f = vmid(rows, "sfm"), vmid(rows, "fz")
        res.append(dict(vendor=k[0], family=k[1], op=k[2], band=k[3], eng=k[4], n=len(rows), ok=True, e_sfm=o["sfm"], v_sfm=s, e_fz=o["fz"], v_fz=f,
                        v_sfm_max=C.span(rows, "sfm")[1], limited=o["limited_by"]))
    json.dump(res, open(sys.argv[1], "w"))
    print(len(res), sum(r["ok"] for r in res))
