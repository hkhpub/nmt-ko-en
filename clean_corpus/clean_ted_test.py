import xml.etree.ElementTree as ET
from argparse import ArgumentParser


def parse_args():
    p = ArgumentParser('Remove meta tags from iwslt18 train files')
    p.add_argument(
        '--input',
        type=str, metavar='FILE', required=True, help='raw corpus file')
    p.add_argument(
        '--output',
        type=str, metavar='FILE', required=True, help='cleaned corpus file')

    return p.parse_args()


if __name__ == '__main__':
    args = parse_args()

    wf = open(args.output, "w")
    tree = ET.parse(args.input)
    root = tree.getroot()
    for seg in root.iter("seg"):
        wf.write(seg.text+"\n")

    wf.close()

