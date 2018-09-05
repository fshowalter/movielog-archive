const DraftLog = require('draftlog');
const chalk = require('chalk');

const dependencies = {
  DraftLog,
};

const formatProgress = (progress) => {
  const bytesToMegabytes = bytes => Math.ceil(bytes / 1000000);

  const transferred = bytesToMegabytes(progress.transferred);
  const total = bytesToMegabytes(progress.total);

  return `${' '.repeat(3 - transferred.length)}${chalk.dim(transferred)}M/${total}M`;
};

const onPathReady = (path) => {
  global.console.log(chalk.dim('Downloading to ') + chalk.white(path) + chalk.dim('...'));
};

const onDone = () => {
  global.console.log(chalk.bold.green('All files downloaded!'));
};

const onStartFile = (file, fileEventEmitter) => {
  const fileColumn = file + ' '.repeat(30 - file.length);
  const draftlog = global.console.draft();

  const onFileProgress = (progress) => { draftlog(fileColumn + formatProgress(progress)); };
  const onFileDone = () => draftlog(fileColumn + chalk.bold.green('Done!'));

  fileEventEmitter.on('progress', onFileProgress);
  fileEventEmitter.on('done', onFileDone);
};

const reportDownloaderProgress = (downloader) => {
  dependencies.DraftLog(global.console);

  downloader.on('pathReady', onPathReady);
  downloader.on('startFile', onStartFile);
  downloader.on('done', onDone);

  return downloader;
};

module.exports = { reportDownloaderProgress, dependencies };
