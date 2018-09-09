const chalk = require('chalk');
const reportFileDownloaderProgress = require('./reportFileDownloaderProgress');

const onPathReady = path => {
  global.console.log(chalk.dim('Downloading to ') + chalk.white(path) + chalk.dim('...'));
};

const onDone = () => {
  global.console.log(chalk.bold.green('All files downloaded!'));
};

const reportOrchestratorProgress = orchestrator => {
  orchestrator.on('pathReady', onPathReady);
  orchestrator.on('startFile', reportFileDownloaderProgress);
  orchestrator.on('done', onDone);

  return orchestrator;
};

module.exports = { reportOrchestratorProgress };
