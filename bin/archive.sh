#!/bin/bash

rm -rf /tmp/adjudication-engine.zip /tmp/adjudication-engine
git clone . /tmp/adjudication-engine --branch starting-point

cd /tmp/adjudication-engine
rm -rf .git
git init
git add .
git commit -m "Too much work for me. Can you finish this?"
cd ..

zip -r adjudication-engine.zip adjudication-engine/

echo /tmp/adjudication-engine.zip
