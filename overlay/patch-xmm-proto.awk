BEGIN {
	setup_replacements = 0
	validation_replacements = 0
}

$0 == "\tDATA=$(CID=$profile DNSQUERY=$DNSQUERY gcom -d $device -s /etc/gcom/xmm-config.gcom)" {
	print "\tip4mask=24"
	print "\tip4addr="
	print "\tlladdr="
	print "\tfor attempt in $(seq 1 $maxfail); do"
	print "\t\tDATA=$(CID=\"$profile\" DNSQUERY=\"$DNSQUERY\" gcom -d \"$device\" -s /etc/gcom/xmm-config.gcom)"
	print "\t\tip4addr=$(echo \"$DATA\" | awk -F [,] '/^\\+CGPADDR/{gsub(\"\\r|\\\"\", \"\"); print $2}') >/dev/null 2>&1"
	print "\t\tlladdr=$(echo \"$DATA\" | awk -F [,] '/^\\+CGPADDR/{gsub(\"\\r|\\\"\", \"\"); print $3}') >/dev/null 2>&1"
	print "\t\tif valid_ip4 \"$ip4addr\" && [ \"$ip4addr\" != \"0.0.0.0\" ]; then"
	print "\t\t\tbreak"
	print "\t\tfi"
	print "\t\t[ \"$attempt\" -lt \"$maxfail\" ] || break"
	print "\t\techo \"Waiting for IPv4 address ($attempt/$maxfail)\""
	print "\t\tsleep 3"
	print "\tdone"
	getline
	getline
	setup_replacements++
	next
}

$0 == "\t\t$(valid_ip4 $n) && {" {
	print "\t\tvalid_ip4 \"$n\" && {"
	validation_replacements++
	next
}

$0 == "\t\t$(valid_ip4 $ip4addr) && [ \"$ip4addr\" != \"0.0.0.0\" ] && {" {
	print "\t\tvalid_ip4 \"$ip4addr\" && [ \"$ip4addr\" != \"0.0.0.0\" ] && {"
	validation_replacements++
	next
}

{ print }

END {
	if (setup_replacements != 1 || validation_replacements != 2) {
		print "Unsupported xmm.sh layout; patch was not applied" > "/dev/stderr"
		exit 42
	}
}
