const { existsSync, mkdirSync } = require('fs');

const dependencies = {
  existsSync,
  mkdirSync
};

const DOWNLOAD_DIR = 'movieDbData';

const ensureDownloadPath = () => {
  const zeroPad = number => number.toString().padStart(2, '0');

  const date = new Date(Date.now());
  const year = date.getFullYear();
  const month = zeroPad(date.getMonth() + 1);
  const day = zeroPad(date.getDate());
  const path = `${DOWNLOAD_DIR}/${year}${month}${day}`;

  if (!dependencies.existsSync(path)) {
    dependencies.mkdirSync(path);
  }

  return path;
};

module.exports = { ensureDownloadPath, dependencies };
