#!/usr/bin/env bash

swww query | awk -F 'image: ' '{print $2}' | head -n1
