const express = require("express");
const app = express();
// const port = 7867

require("dotenv").config(); // load configuration
app.use(express.static(process.env.DATA_DIR)); // allow access to data resources

// const cors = require("cors");
// app.use(cors({ origin: "*", }));

const dirTree = require("directory-tree");

const path = require("path");
const fs = require("fs");

/**
 * @dev test api
 */
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

/**
 * @dev callback used to process information usefull for client application
 */
function dirTreeCallBack(item) {
  item.label = item.name;
  item.key = `_${item.path}`;
  item.parent = item.type === 'directory';
}

/**
 * @dev return a directory structure tree
 */
app.get(`/data`, (_, res) => {
  const tree = dirTree(
    process.env.DATA_DIR,
    {
      attributes: ["size", "type", "extension"],
      extensions: /\.(md|png|jpg)$/
    },
    dirTreeCallBack,
    dirTreeCallBack
  );
  console.log(tree.children);
  res.json(tree.children ?? []);
});

/**
 * @deprecated
 */
app.get("/api/v1/data", (req, res) => {
  const _path = req.query.path;
  console.log(_path);
  const _file = fs.readFileSync(path.join(__dirname, _path), 'utf-8');
  res.json({
    status: true,
    data: _file
  });
});

/**
 * @dev run application
 */
app.listen(process.env.PORT, () => {
  console.log(`Listen on port ${process.env.PORT}`);
});
