import json


with open("mongo_db_dump.json") as f:
    x = json.loads(f.read())


tree = {}

for entry in x:
    for p in entry["path"].replace("/           /","           /           /").split("           /           /"):
        path = p.strip().split("/")
        prev = tree
        for each in path:
            prev = prev.setdefault(each, {})

final_tree = []


def fillnode(key, value, nodearr, level):
    newnode = {}

    newnode.setdefault("text",key.replace("WellBeing", "Well Being")) #database error
    newnode.setdefault("level", level)
    newnode.setdefault("selectable",True)
    newnode.setdefault("showIcon",False)
    newnode.setdefault("keyword", "doc?kw={}".format(key.replace('  ', ' ').replace(' ', '+')))
    
    if value != {}: #if there are children in the hierarchy for this discipline
        newnode["selectable"] = False #we can select on the end
        newnode.pop('href', None)
        rec = newnode.setdefault("nodes", []) #create a new array in node, recurse
        for k, v in value.iteritems():
            fillnode(k, v, rec, level+1)
        newnode['nodes'] = sorted(rec, key=lambda k: k['text']) #keep the list sorted
    nodearr.append(newnode)

for k,v in tree.iteritems():
    fillnode(k, v, final_tree, 0)

final_final_tree = []
for t in final_tree:
    if "nodes" in t:
        final_final_tree.append(t)

final_final_tree = sorted(final_final_tree, key=lambda k: k['text'])  #keep the list sorted


json_tree = {"all":final_final_tree}
with open("discipline_hierarchy.json", 'w') as f:
    f.write(json.dumps(json_tree))

# for t in final_tree:
#     print "{" + "\n".join("{}: {}".format(k, v) for k, v in t.items()) + "}"
