import json
import urllib2
from distutils.version import StrictVersion

def versions(package_name):
    url = "https://pypi.org/pypi/%s/json" % (package_name,)
    data = json.load(urllib2.urlopen(urllib2.Request(url)))
    versions = data["releases"].keys()
    return versions

print "\n".join(versions("rucio"))
