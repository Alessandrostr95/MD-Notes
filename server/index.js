const express = require("express");
const app = express();
const port = 7867
app.use(express.static("data"));

// const cors = require("cors");
// app.use(cors({ origin: "*", }));

const dirTree = require("directory-tree");

const path = require("path");
const fs = require("fs");

app.get("/test", (_, res) => {
  console.log("test request received");
  res.json([
    {
      label: 'documents',
      key: 'docs',
      children: [
        { key: 'A', label: 'document A' },
        { key: 'B', label: 'document B' },
        {
          key: 'sub_dir',
          label: 'sub document',
          children: [
            { key: 'C', label: 'document C' }
          ]
        }
      ]
    },
    {
      label: "other",
      key: "other"
    }
  ]);
});

function dirTreeCallBack(item) {
  item.label = item.name;
  if (item.type === 'directory') {
    item.key = `#${item.path}`;
    item.parent = true;
    // item.icon = "Icons.folder";
  } else {
    item.parent = false;
    item.key = `_${item.path}`;
  }
}

app.get("/data", (_, res) => {
  const tree = dirTree(
    "data",
    {
      attributes: ["size", "type", "extension"],
      extensions: /\.(md|png|jpg)$/
    },
    dirTreeCallBack,
    dirTreeCallBack
  );
  console.log(tree.children);
  res.json(tree.children);
});

app.get("/api/v1/data", (req, res) => {
  const _path = req.query.path;
  console.log(_path);
  const _file = fs.readFileSync(path.join(__dirname, _path), 'utf-8');
  res.json({
    status: true,
    data: _file
  });
});

app.listen(port, () => {
  console.log(`Listen on port ${port}`);
});

