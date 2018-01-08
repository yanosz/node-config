#!/bin/sh
#Fixme: Neighbor table for bat0 in json
bat_neigh() {
	IFS=$'\n' 
	for  neigh in `batctl n | tail -n +3`; do
		echo $neigh | sed -e 's/ ..: /aa/g' 
	done
}
