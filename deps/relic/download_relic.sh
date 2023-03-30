#!/bin/bash

VERSION=0.6.0
FORMAT=tar.gz
LINK=https://github.com/relic-toolkit/relic
RELIC=${1:-relic-toolkit-${VERSION}}

# commit of as of 22/06/2022
# comment 'Update LABEL with recent changes'
COMMIT=40f24f017d461647ce6202c3ccaae3c22037369c

# This below is the latest commmit before "Massive renaming of symbols to include prefix RLC.",
# a commit that changes a lot of symbols and stuff (so do not use commits after that, unless you
# want to fix all references in OpenABE source code)
# comment 'Massive commit to update copyright.'
#COMMIT=f624aa8a65e7787bdc2bd070f4bc8fd5d370ae85

echo "Clone github repo @ ${LINK}"
git clone ${LINK} ${RELIC}.git
cd ${RELIC}.git
git checkout ${COMMIT}
git remote add tyler https://github.com/tylerliu/relic
git fetch tyler
git config user.email "you@example.com"
git config user.name "Your Name"
git cherry-pick 6c383a1e97971fb342dc406a1b5da82af3df8b40

if [[ ! -f ${RELIC}.${FORMAT} ]]; then
   echo "Create archive of source (without git files)"
   git archive --output ../${RELIC}.test.${FORMAT} HEAD

   echo "Create final tarball: ${RELIC}.${FORMAT}"
   cd ..
   mkdir ${RELIC}
   cd ${RELIC}
   tar -xf ../${RELIC}.test.${FORMAT}

   echo "Fix symbols..."
   grep -rl "MIN" ./ | xargs sed --in-place 's/MIN/RLC_MIN/g'
   grep -rl "MAX" ./ | xargs sed --in-place 's/MAX/RLC_MAX/g'
   grep -rl "ALIGN" ./ | xargs sed --in-place 's/ALIGN/RLC_ALIGN/g'
   grep -rl "rsa_t" ./ | xargs sed --in-place 's/rsa_t/rlc_rsa_t/g'
   grep -rl "rsa_st" ./ | xargs sed --in-place 's/rsa_st/rlc_rsa_st/g'
   sed --in-place -e '/^#define ep2_mul /d' include/relic_label.h

   cd ..
   tar -czf ${RELIC}.${FORMAT} ${RELIC}
   rm ${RELIC}.test.${FORMAT}
   rm -r ${RELIC}
else
   echo "[!] ${RELIC}.tar.gz already exists."
fi
