				% # Convert CSS highlighting classes to a semantic description of the document type (always plural)
				% # XXX: what is this actually for again..?
				% highlight_classes_to_doctypes = {}
				% highlight_classes_to_doctypes['highlight-portal-orange'] = "YoRHa Type 2B androids"
				% highlight_classes_to_doctypes['highlight-portal-blue'] = "YoRHa Type 9S androids"
				% highlight_classes_to_doctypes['highlight-luka'] = "YoRHa Type A2 androids"
				% highlight_classes_to_doctypes['highlight-miku'] = "YoRHa operators"
				% highlight_classes_to_doctypes[''] = "documents of unknown origin"
				%
				% # Use json for encoding strings
				% import json
				% # For creating links to the umad-indexer
				% from urllib import urlencode
				% # We'll use this a lot
				% other_metadata = hit['other_metadata']
				% id = hit['id']

				<li class="result-card {{ hit['highlight_class'].encode('utf8') }}">
				<div class="hitlink">
					% linktext = other_metadata.get('name', id)
					% linktext = other_metadata.get('title', linktext)
					% customer_name = other_metadata.get('customer_name', u'')
					% if customer_name:
						% customer_name = u'↜ {0}'.format(customer_name)
					% end
					% doc_type = other_metadata.get('doc_type')
					% if doc_type:
						% del(other_metadata[doc_type])
					% end
					<a href="{{ id.encode('utf8') }}" onClick="evilUserClick({{ json.dumps(hit) }})">{{ linktext.encode('utf8') }}</a> <span class="customer-name">{{ customer_name.encode('utf8') }}</span> <span class="document-score">scored {{ hit['score'] }}</span>
				</div>

				% if "name" in other_metadata or "title" in other_metadata:
				<div class="hiturl">{{ id.encode('utf8') }}</div>
				% end

				<span class="excerpt">{{! hit['extract'].encode('utf8') }}</span><br />

				<!-- WE DON'T HAVE A REINDEXER DAEMON RIGHT NOW, HIDE THE BUTTON
				<div class="reindex-button">
					% umad_indexer_query_string = urlencode({'url':id.encode('utf8')})
					<span class="lsf" title="Reindex this result"><a href="https://umad-indexer.example.com/?{{! umad_indexer_query_string }}" target="_blank" onClick="evilUserReindex({{ json.dumps(hit) }})">sync</a></span>
				</div>
				-->

				<div class="metadata-button">
					<span class="lsf">tag</span>

					% # Only if the list is non-empty
					% if other_metadata:
						% # Don't need to print these keys, they're already part of the main display
						% if 'excerpt' in other_metadata:
							% del(other_metadata['excerpt'])
						% end
						% if 'title' in other_metadata:
							% del(other_metadata['title'])
						% end
						% if 'doc_type' in other_metadata:
							% del(other_metadata['doc_type'])
						% end
						% if 'public_blob' in other_metadata:
							% del(other_metadata['public_blob'])
						% end
					<div class="other-metadata">
						Other metadata
						<ul>
						% for key in sorted(other_metadata):
							% metadata_value = other_metadata[key]
							% # Not quite ideal, we should really be catching any "real" iterable (list/dict/tuple), and falling back to default for anything else
							% if isinstance(metadata_value, (str, unicode)):
								<li class="metadata"><strong>{{ key.encode('utf8') }}:</strong> {{ metadata_value.encode('utf8') }}</li>
							% elif isinstance(metadata_value, (bool, int)):
								<li class="metadata"><strong>{{ key.encode('utf8') }}:</strong> {{ "{0}".format(metadata_value) }}</li>
							% else:
								<li class="metadata"><strong>{{ key.encode('utf8') }}:</strong> {{ ', '.join(sorted(metadata_value)).encode('utf8') }}</li>
							% end
						% end
						</ul>
					</div>
					% end
				</div>
				</li>

