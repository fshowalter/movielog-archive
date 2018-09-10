const DraftLog = require('draftlog');
const chalk = require('chalk');

const dependencies = {
  DraftLog
};

const formatProgress = ({ transferred, total }) => {
  const bytesToMegabytes = bytes => Math.ceil(bytes / 1000000);

  const transferredMb = bytesToMegabytes(transferred);
  const totalMb = bytesToMegabytes(total);

  return `${' '.repeat(3 - transferredMb.length)}${chalk.dim(transferredMb)}M/${totalMb}M`;
};

const reportDownloadProgress = ({ file, emitter }) => {
  dependencies.DraftLog(global.console);

  const fileColumn = file + ' '.repeat(30 - file.length);
  const draftlog = global.console.draft;

  const onProgress = progress => {
    draftlog(fileColumn + formatProgress(progress));
  };

  const onDone = () => draftlog(fileColumn + chalk.bold.green('Done!'));

  emitter.on('progress', onProgress);
  emitter.on('done', onDone);
};

module.exports = { reportDownloadProgress, dependencies };
