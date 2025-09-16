# RNA-seq workflow
## Basic Linux commands
```bash
# 每次成功登录进入都是账户的home目录(~)，windows系统习惯把"目录"叫成"文件夹"
# 进入新的目录，"ls"查看该目录包含哪些文件或者目录
# yfchen@hnu2024 Tue Sep 16 09:35:28 ~
ls

# 可以看到有"RNA_seq/"
# cd进入该目录
# 写命令的时候可以尝试用tab键补齐
# yfchen@hnu2024 Tue Sep 16 09:51:28 ~
cd RNA_seq/
# yfchen@hnu2024 Tue Sep 16 09:57:36 ~/RNA_seq
ls

# 查看所有文件的属性(文件权限、大小、更改时间)
ll
# chown更改文件所属
# chown user:group file
# 更改文件属性属于高级权限，需要以管理员身份(sudo)才能运行
sudo chown yfchen:yfchen DaruB10_R1.fq.gz
# for循环一次性改完所有的文件
for i in *.gz;do sudo chown yfchen:yfchen ${i};done
# 文件所属改完之后，看到这些fq文件是绿色，是可执行文件(x)
# 但是这些文件不是脚本，因此不是可执行文件，可将权限再次修改
# r:4; w:2; x:1
# yfchen@hnu2024 Tue Sep 16 09:52:25 ~/RNA_seq
chmod 644 DaruB10_R1.fq.gz
# 可用"ll"查看文件属性
# 看到绿色消失，说明这个文件没有执行权限了
ll DaruB10_R1.fq.gz
# for循环一次性改完所有的文件
for i in *.gz;do chmod 644 ${i};done
```
## software install
```bash
# 所有安转的软件都放在一个目录
# fastqc:评估fq文件质量
# trimmomatic:将质量差的序列移除
# 建议放在home目录下
# yfchen@hnu2024 Tue Sep 16 10:10:05 ~/RNA_seq
cd ~
# 创建进入software目录
mkdir software; cd software

# 1. fastqc安装
# 下载fastqc
# yfchen@hnu2024 Tue Sep 16 10:18:39 ~/software
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip
# 然后开始下载，下载完毕之后可看到fastqc_v0.12.1.zip
# unzip解压，解压完之后可看到FastQC目录
unzip fastqc_v0.12.1.zip
# yfchen@hnu2024 Tue Sep 16 10:18:39 ~/software
cd FastQC
# yfchen@hnu2024 Tue Sep 16 10:21:09 ~/software/FastQC
ls
# 可看到可执行文件fastqc
./fastqc --help # 查看如何运行fastqc
# 如果不把可执行文件fastqc所在的目录添加至环境变量，那如果在其他目录运行fastqc，都得带上fastqc所在的目录
# 例如：RNA_seq/
# yfchen@hnu2024 Tue Sep 16 10:25:17 ~/software/FastQC
cd ~/RNA_seq/
# yfchen@hnu2024 Tue Sep 16 10:28:41 ~/RNA_seq
~/software/FastQC/fastqc --help
# 可把可执行文件fastqc所在的目录添加至环境变量
# 添加方法：添加至~/.bashrc文件
# vi编辑文件，可网络搜索或者书上看下怎么用vi
# yfchen@hnu2024 Tue Sep 16 10:28:41 ~/RNA_seq
vi ~/.bashrc
# 把下面这行添加至文件末尾；后续安装的新软件可以在冒号后面继续添加
# export PATH=$PAHT=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/home/:~/software/FastQC:
source ~/.bashrc
# 然后就可以在任意目录使用fastq(无需在命令前面添加安装目录)

# 2. trimmomatic安装
# 下载trimmomatic
# yfchen@hnu2024 Tue Sep 16 10:41:01 ~/software
wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.39.zip
unzip Trimmomatic-0.39.zip
# 解压完毕后，进入Trimmomatic-0.39；发现java程序trimmomatic-0.39.jar
# java程序的使用无需添加至环境目录，直接拷贝至运行目录进行使用
# yfchen@hnu2024 Tue Sep 16 10:55:28 ~/software
cd Trimmomatic-0.39;ls
```

## 1. fastqc进行质量检测
```bash
# yfchen@hnu2024 Tue Sep 16 10:59:11 ~/RNA_seq
mkdir fastqc1
# 运行；必须了解每一个参数代表什么意思
fastqc *.gz -o ./fastqc1 --extract -t 20
# 运行时间过长的时候，可以用nohup提交至后台，就可以继续做其他的事情了
nohup fastqc *.gz -o ./fastqc1 --extract -t 20 > fastqc1.process 2>&1 &
top # top命令查看
# 如果不用nohup，也可以重新开一个窗口，这样也可以继续做其他的事情了
# 运行结束之后查看每个结果文件里面的summary.txt，统计里面fail项

# fastqc运行完之后，统计结果中出现各个项目中出现fail的次数
# yfchen@hnu2024 Tue Sep 16 11:51:43 ~/RNA_seq
perl fq_summary.pl fastqc1
```

## 2. Trimmomatic过滤
```bash
# yfchen@hnu2024 Tue Sep 16 11:54:54 ~/RNA_seq
mkdir -p Trimmomatic/paired/
mkdir -p Trimmomatic/unpaired/
# copy运行Trimmomatic所需的java程序和adapter文件
cp ~/software/Trimmomatic-0.39/trimmomatic-0.39.jar ./
cp ~/software/Trimmomatic-0.39/adapters/TruSeq2-PE.fa ./

# 参考http://www.usadellab.org/cms/?page=trimmomatic，了解每个参数的意思以及如何运行
# 试运行
# java -jar trimmomatic-0.39.jar PE input_reverse.fq.gz output_forward_paired.fq.gz output_forward_unpaired.fq.gz output_reverse_paired.fq.gz output_reverse_unpaired.fq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:36

java -jar trimmomatic-0.39.jar PE DaruB10_R1.fq.gz DaruB10_R2.fq.gz Trimmomatic/paired/DaruB10_R1.paired.fq.gz Trimmomatic/unpaired/DaruB10_R1.unpaired.fq.gz Trimmomatic/paired/DaruB10_R2.paired.fq.gz Trimmomatic/unpaired/DaruB10_R2.unpaired.fq.gz ILLUMINACLIP:TruSeq2-PE.fa:2:30:10 LEADING:4 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:40 -threads 10

# 一次性运行全部，nohup提交至后台运行，可用top查看
nohup perl run_trimmo.pl TruSeq2-PE.fa > run_trimmo.process 2>&1 &
```

## 3. fastqc对过滤后的数据进行质量检测
```bash
# Trimmomatic运行完之后
# yfchen@hnu2024 Tue Sep 16 13:48:13 ~/RNA_seq
mkdir fastqc2
nohup fastqc Trimmomatic/paired/*.gz -o ./fastqc2 --extract -t 20 > fastqc2.process 2>&1 &

# 根据比较Trimmomatic过滤前后结果的差距
perl fq_summary.pl fastqc2
# FAIL	Per base sequence content	4
# FAIL	Sequence Duplication Levels	7
```
