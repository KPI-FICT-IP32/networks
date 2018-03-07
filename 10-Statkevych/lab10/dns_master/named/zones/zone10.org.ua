$TTL    604800
@   IN  SOA zone10.org.ua. root.zone10.org.ua. (
				  2     ; Serial
			 604800     ; Refresh
			  86400     ; Retry
			2419200     ; Expire
			 604800 )   ; Negative Cache TTL
;
@		IN	NS	zone10.org.ua.

zone10.org.ua.		IN	A	10.18.51.2


; host configuration
mercury		IN	A	172.21.11.10
venus		IN	A	172.21.11.20
earth		IN	A	172.21.11.30
saturn		IN	A	172.21.11.40
jupyter		IN	A	172.21.11.50
mail		IN	A	172.21.11.60

; aliases
machine-1		IN	CNAME	mercury
machine-2		IN	CNAME	venus
machine-3		IN	CNAME	earth
machine-4		IN	CNAME	saturn
machine-5		IN	CNAME	jupyter


; mail configuration
smtp	IN	MX	10	mail

; reverse for mail
60 		IN 	PTR	mail