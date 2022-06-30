#!/bin/bash
 
 
#
# Get tag list for specific image
#
 
registry='registry.domain.com'
list_limit=10000
name='some-image'
delete_tag='dev'
 
for tag in $(curl -k -s -X GET https://${registry}/v2/_catalog?n=${list_limit} | jq '.repositories[]' | sort | grep "${name}" | xargs -I _ curl -s -k -X GET https://${registry}/v2/_/tags/list | jq '.tags' | sed 's/[",, ]//g' | sort );
 
do
 
if [[ $tag = $delete_tag ]];
then
 
curl -X DELETE -sI -k "https://${registry}/v2/${name}/manifests/$(
  curl -sI -k \
    -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    "https://${registry}/v2/${name}/manifests/${delete_tag}" \
    | tr -d '\r' | sed -En 's/^Docker-Content-Digest: (.*)/\1/pi'
)";
 
fi;
 
done;
 
#
# And run this command on docker-distribution-node1 or docker-distribution-node2 for finalize cleanup
#
# registry garbage-collect /etc/docker/registry/config.yml
#
