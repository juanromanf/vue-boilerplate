import express from 'express'
import bodyParser from 'body-parser'

const app = express()

app.disable('x-powered-by')

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))

app.get('/', (req, res, next) => {
  res.send({response: 'Hello World!'})
})

app.use((req, res, next) => {
  const err = new Error('Not Found')
  err.status = 404
  next(err)
})

app.use((err, req, res, next) => {
  console.error(err)
  res
    .status(err.status || 500)
    .render('error', {
      message: err.message
    })
})

const { PORT = 3000 } = process.env
app.listen(PORT, () => console.log(`Listening on port ${PORT}`))
