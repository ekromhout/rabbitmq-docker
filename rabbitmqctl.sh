#!/bin/bash
sleep 5
rabbitmqctl trace_on
tail -f /dev/null
