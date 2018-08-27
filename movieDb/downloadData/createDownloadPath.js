const { existsSync, mkdirSync } = require('fs');

const dependencies = {
  existsSync,
  mkdirSync,
};

const createDownloadPath = (baseDir) => {
  const zeroPad = number => number.toString().padStart(2, '0');

  const date = new Date(Date.now());
  const year = date.getFullYear();
  const month = zeroPad(date.getMonth() + 1);
  const day = zeroPad(date.getDate());
  const path = `${baseDir}/${year}${month}${day}`;

  if (!dependencies.existsSync(path)) {
    dependencies.mkdirSync(path);
  }

  return path;
};

module.exports = { createDownloadPath, dependencies };
