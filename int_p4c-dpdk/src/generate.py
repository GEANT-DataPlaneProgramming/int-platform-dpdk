# 
#  Copyright 2020 PSNC
# 
#  Author: Pavlína Patová
# 
#  Created in the GN4-3 project.
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# 
#
#  /////////////////////////////////////////////////////////////////////////////////////////////////////////
from jinja2 import Template
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-n', default=4, help='Maximum number of transit nodes')
parser.add_argument('-m', default='0xffffffffffff', help='MAC address of next node')
parser.add_argument('-t', action='store_true', help='Generate transit')
parser.add_argument('-c', action='store_true', help='Generate source')
parser.add_argument('-r', action='store_true', help='Generate header.p4')
parser.add_argument('-s', action='store_true', help='Generate sink.p4')
parser.add_argument('-g', action='store_true', help='Don\'t use default rules.')

parser.add_argument('-d', default=32, help='Set dscp')
parser.add_argument('-p', default=63, help='Dscp mask')
parser.add_argument('-l', default=6, help='Hop meta len')
parser.add_argument('-a', default=12, help='Mask 1')
parser.add_argument('-k', default=12, help='Mask 2')
parser.add_argument('-i', default=6, help='Shim header len')
parser.add_argument('-b', default=14, help='Header len bytes')
parser.add_argument('-w', default=4, help='Report header len words')


args = parser.parse_args()
node_number = int(args.n)
mac_addr = args.m
dscp_mask = args.p

int_dscp = args.d
meta_len = args.l
mask1 = int(args.a)
mask2 = int(args.k)

shim = args.i
hdr_len    = args.b
report_len= args.w

if args.m == "0xffffffffffff":
    change_mac = ""
else:
    change_mac = "test_update_addresses();"

source = "int/int_template.p4"
result = "int/int.p4"

if args.r == True:
    print("Generating headers.p4...")
    file = open("headers_template.p4", "r")
    template = Template(file.read())
    file = open("headers.p4", "w")
    file.write(template.render(\
    n = "{:02x}".format(node_number), \
    d = hex(int_dscp),\
    l = meta_len,\
    a = mask1,\
    k = mask2,\
    i = int(shim),\
    b = int(hdr_len),\
    w = int(report_len),\
    p = hex(dscp_mask)\
    ))

if args.t == True:
    print("Generating transit...")  
    file = open(source, "r")
    template = Template(file.read())
    file = open(result, "w")
    file.write(template.render(mac = mac_addr, call = change_mac, s = 0, c = 0, g = args.g))

if args.c == True:
    print("Generating source...")
    file = open(source, "r")
    template = Template(file.read())
    file = open(result, "w")
    file.write(template.render(mac = mac_addr, call = change_mac, s = 0, c = 1, g = args.g))

if args.s == True:
    print("Generating sink.p4...")  
    file = open(source, "r")
    template = Template(file.read())
    file = open(result, "w")
    file.write(template.render(mac = mac_addr, call = change_mac, s = 1, c = 0, g = args.g))