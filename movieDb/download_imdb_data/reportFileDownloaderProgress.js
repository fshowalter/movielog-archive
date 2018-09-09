const DraftLog = require('draftlog');
const chalk = require('chalk');

const dependencies = {
  DraftLog
};

const formatProgress = progress => {
  const bytesToMegabytes = bytes => Math.ceil(bytes / 1000000);

  const transferred = bytesToMegabytes(progress.transferred);
  const total = bytesToMegabytes(progress.total);

  return `${' '.repeat(3 - transferred.length)}${chalk.dim(transferred)}M/${total}M`;
};

const reportFileDownloaderProgress = fileDownloader => {
  dependencies.DraftLog(global.console);

  const fileColumn = fileDownloader.file + ' '.repeat(30 - fileDownloader.file.length);
  const draftlog = global.console.draft();

  const onFileProgress = progress => {
    draftlog(fileColumn + formatProgress(progress));
  };

  const onFileDone = () => draftlog(fileColumn + chalk.bold.green('Done!'));

  fileDownloader.on('progress', onFileProgress);
  fileDownloader.on('done', onFileDone);
};

module.exports = { reportFileDownloaderProgress, dependencies };
