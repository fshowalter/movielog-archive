/* eslint no-console: "off" */

const DraftLog = require('draftlog');
const fs = require('fs');
const got = require('got');
const { exec } = require('child_process');

const defaults = {
  downloadDir: 'movieDbData',
  filesToDownload: [
    'title.basics.tsv.gz',
    'title.principals.tsv.gz',
    'name.basics.tsv.gz',
  ],
};

const dependencies = {
  got,
  fs,
  exec,
  DraftLog,
};

const unzipFile = (file, callback) => {
  dependencies.exec(`gunzip -f ${file}`, callback);
};

const unzippedFileExists = (zippedFile, downloadPath) => {
  const unzippedFile = zippedFile.replace(/\.gz$/, '');

  return dependencies.fs.existsSync(`${downloadPath}/${unzippedFile}`);
};

const createDownloadPath = (dir) => {
  const zeroPad = number => number.toString().padStart(2, '0');

  const date = new Date(Date.now());
  const year = date.getFullYear();
  const month = zeroPad(date.getMonth() + 1);
  const day = zeroPad(date.getDate());
  const path = `${dir}/${year}${month}${day}`;

  if (!dependencies.fs.existsSync(path)) {
    dependencies.fs.mkdirSync(path);
  }

  return path;
};

const bytesToMegabytes = bytes => Math.ceil(bytes / 1000000);

const getWithProgress = (file, downloadPath) => {
  const reporter = console.draft();
  const fillSpaces = ' '.repeat(30 - file.length);

  if (unzippedFileExists(file, downloadPath)) {
    return Promise.resolve();
  }

  const fileWithPath = `${downloadPath}/${file}`;

  return new Promise((resolve) => {
    dependencies.got.stream(`https://datasets.imdbws.com/${file}`)
      .on('downloadProgress', (progress) => {
        reporter(`${file}${fillSpaces}Downloading: ${bytesToMegabytes(progress.transferred)}/${bytesToMegabytes(progress.total)} MB`);
      })
      .on('error', (error) => {
        reporter(`${file}${fillSpaces}Download error: ${error}`);
        return resolve();
      })
      .pipe(dependencies.fs.createWriteStream(fileWithPath)
        .on('finish', () => {
          reporter(`${file}${fillSpaces}Unzipping...`);
          unzipFile(fileWithPath, () => {
            reporter(`${file}${fillSpaces}Done!`);
            return resolve();
          });
        }));
  });
};

const downloadData = async () => {
  DraftLog(console);

  const downloadPath = createDownloadPath(defaults.downloadDir);
  console.log(`Downloading to ${downloadPath}...`);


  const promises = defaults.filesToDownload.map(
    file => getWithProgress(file, downloadPath),
  );

  try {
    await Promise.all(promises);
    console.log('All downloads complete!');
  } catch (error) {
    console.log(error);
  }

  return downloadPath;
};

module.exports = { defaults, dependencies, downloadData };
