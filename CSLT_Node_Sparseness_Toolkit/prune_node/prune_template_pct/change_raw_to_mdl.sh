#!/bin/bash

sed -i '$d' final_new.raw

cat prefix.mdl final_new.raw suffix.mdl >> final_new.mdl
