const program = require('commander');

const { downloadData } = require('./movieDb/downloadData');

program
  .version('0.0.1')
  .description('Frank\'s Movielog');

program
  .command('update')
  .action(() => {
    downloadData();
  });

program.parse(process.argv);
