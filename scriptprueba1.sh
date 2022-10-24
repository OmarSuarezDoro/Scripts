#!/bin/bash

echo $(($(ps -u $USER | wc -l) + $(ps -u root | wc -l)))
