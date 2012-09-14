express = require('express')
redis = require('redis')

db = redis.createClient()

app = express()
app.use(express.bodyParser({ keepExtensions: true, uploadDir: __dirname + '/static/uploads' }))
app.use(express.static(__dirname + '/static'))

app.set('views', __dirname + '/views')
app.engine('html', require('ejs').renderFile)

app.get('/', (req, res) ->
  res.render('index.html')
)

app.post('/audioupload', (req, res) ->
  console.log req.files
  res.render 'index.html' )

app.listen(3666)
