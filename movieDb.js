const program = require('commander');

const { createDownloader, reportDownloaderProgress } = require('./movieDb/downloadData');

program
  .version('0.0.1')
  .description('Frank\'s Movielog');

program
  .command('update')
  .action(async () => {
    const downloader = createDownloader();
    reportDownloaderProgress(downloader).start();
  });

program.parse(process.argv);
