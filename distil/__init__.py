import local_file


class BadUrl(Exception): pass

class NoUrlHandler(Exception): pass

class Distiller(object):
	def __init__(self, url, indexer_url=None):
		self.url = url
		self.indexer_url = indexer_url
		self.fetcher = None
		self.docs = [] # Each element looks like:  { 'url':"foo", 'blob':"bar" }

		# Tidy the URL here if needed
		self.init_fetcher()
		self.blobify()


	def init_fetcher(self):
		'''Find a module with fetch and blobify capabilities that's suitable for the URL provided'''
		url = self.url

		try:
			#print "Testing for fetcher with url: %s (type is %s)" % (url, type(url))
			if url.startswith('file:///'):
				self.fetcher = local_file

			elif url.startswith('example://your.url.here/'):
				self.fetcher = None
		except:
			raise BadUrl("Your URL '%s' is no good, in some way" % url)

		if self.fetcher is None:
			raise NoUrlHandler("We don't have a module that can handle that URL: %s" % url)


	def blobify(self):
		# XXX: Pass self.indexer_url through to each blobify function.
		# XXX: Should probably be properly-OO and have each distiller subclass this basic distiller.
		self.docs = self.fetcher.blobify(self.url)
