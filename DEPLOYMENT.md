How to deploy UMAD from scratch
===============================

I'm not gonna lie, UMAD is kinda complex and a bit fiddly, so a step by step guide is needed.

Let's understand the components (and I'll write it in that order):

* DB layer (ElasticSearch)
* Web interface for the querying interface
* Distillers (not even strictly necessary)

As a minimum you need a DB and web frontend. These can live on the same node.
**Let's get started with a single node!**


Database layer
--------------

You might add another DB component layer, but we only need ElasticSearch (ES)
to get started.

1. Enable the EPEL repo, you'll probably need it for this bit

2. Install packages
    * `java`
    * `elasticsearch` (tested with 2.3.2 so far)
    * `git` and friends (to pull down the code)

3. Configure ES, we have a single node cluster with no replicas, just one copy of the data
    * Cluster name should be `umad`
    * List of `network.host` is just `localhost`
    * `index.number_of_shards: 1`
    * `index.number_of_replicas: 0`

4. Get the cluster started, make sure it's happy. Use a tool like [elasticsearch-head](https://mobz.github.io/elasticsearch-head/) to connect and check that the ES health is green. You may need to forward tcp/9200 to the server in order to connect.


Web frontend
------------

This part is a bit more fiddly.

1. Git yo'self a user to own and run all the UMAD code
    ```bash
    groupadd srv_umad
    useradd -g srv_umad srv_umad
    ```

2. Create some directories
    ```bash
    su - srv_umad

    mkdir ~/git
    mkdir ~/virtualenvs
    ```

3. Clone the code
    ```bash
    cd ~/git/
    git clone ssh://git@bitbucket:7999/lnx/umad.git
    ```

4. Go in and tweak `localconfig.py` for your local deployment. You'll want to ensure your ES nodes are correct, and you'll need to fiddle with the doctypes for your planned deployment.
    ```python
    ELASTICSEARCH_NODES = [ "127.0.0.1:9200" ]
    ```
    If you're stuck for good doctypes, you can fallback to just *local* for now so it'll run without complaining.
    ```python
    KNOWN_DOC_TYPES = [ 'local' ]

    def determine_doc_type(url):
        if url.startswith('local:///'):
            return 'local'
    ```

5. Setup your virtualenv. A virtualenv contains the runtime environment so that it's isolated (sorta) from other modules installed on the system. We can install Python Cheeseshop packages into the virtualenv sandbox and it won't be seen by other apps on the system.
    ```bash
    # Setup your proxy as needed in your `bash_profile`
    export http_proxy=http://proxy.det.nsw.edu.au:80/
    export https_proxy=http://proxy.det.nsw.edu.au:80/

    # Make the virtualenv and activate it
    cd ~/virtualenvs/
    virtualenv --system-site-packages umad
    . ~/virtualenvs/umad/bin/activate

    # Install pip packages
    pip install colorama termcolor
    ```

6. Now to try running the web interface
    ```bash
    cd ~/git/umad/web_frontend/
    python umad.py
    ```
    By default it listens on `127.0.0.1:8080`, and this is fine for testing. You might need to port-forward to the server to get a connection, but if you visit the URL now you should see the UMAD search homepage.


Getting some data into the ElasticSearch index
----------------------------------------------

Using http://localhost:8080/ is well and good, you get a static webpage. Search is broken because there's no indexes yet. Let's make one.

* Create an index using the ES-head tool, we're going to create `umad_ldap_netgroup`
* We're a single node cluster, so leave the default of 5 shards, but select 0 replicas
* Update `localconfig.py` with your new doctype, something like this:

    ```python
    KNOWN_DOC_TYPES = [ 'ldap_netgroup', 'local' ]

    def determine_doc_type(url):
        if url.startswith('ldap://') and url.endswith(',ou=Netgroup,o=unixteam'):
            return 'ldap_netgroup'
    ```
    Note that the doctypes *don't have a `umad_` prefix*, that's just for index names in ES.
* Write yourself a distiller, this will really be the topic of another guide.
* Run your distiller, it's done something like this:

    ```bash
    python distil_some_stuff.py ldap://cn=es_1node,ou=Netgroup,o=unixteam
    ```

