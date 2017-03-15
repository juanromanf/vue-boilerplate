const { models, sequelize } = require('./api/db')

sequelize.query('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";')
.then(() =>
  sequelize
  .sync({
    force: true
  }))
  .then(() => models.User.create({
    username: 'superadmin',
    password: '999',
    role: 'superadmin'
  }))
  .then(user => console.log(user.toJSON()))