file_path =  'E:/2024计算社会科学夏校/data/musiclab_opendata/musiclab_data/'

# Figure1
import pandas as pd
column_names = ['song_id', 'downloads_in_world1',
                  'downloads_in_world2', 'downloads_in_world3',
                  'downloads_in_world4', 'downloads_in_world5', 
                  'downloads_in_world6', 'downloads_in_world7', 
                  'downloads_in_world8', 'downloads_in_world_independent']

df1 = pd.read_csv(f'{file_path}downloads_v1_lexorder.txt',  names=column_names )

df1.head()

# load the data of downloads_v2_lexorder.txt as df2 below
df2 = pd.read_csv(f'{file_path}downloads_v2_lexorder.txt',  names=column_names )
df2.head()

def gini(list_of_values):
    sorted_list = sorted(list_of_values)
    height, area = 0, 0
    for value in sorted_list:
        height += value
        area += height - value / 2.
    fair_area = height * len(list_of_values) / 2.
    return (fair_area - area) / fair_area

worlds = ['downloads_in_world1',
    'downloads_in_world2', 'downloads_in_world3',
    'downloads_in_world4', 'downloads_in_world5', 
    'downloads_in_world6', 'downloads_in_world7', 
    'downloads_in_world8', 'downloads_in_world_independent'] 

gini_list1 = []
for i in worlds:
    # 计算试验1每一个世界中的gini系数
    # 打印出来计算结果
    # 并append到gini_list1当中
    print(gini(df1[i]))
    gini_list1.append(gini(df1[i]))

gini_list2 = []
for i in worlds:
    # Calculate the gini coefficient in each world in Experiment 2
    # Print out the calculation results
    # And append to gini_list2
    print(gini(df2[i]))
    gini_list2.append(gini(df2[i]))

import matplotlib
import matplotlib.pyplot as plt
matplotlib.style.use('ggplot')

plt.figure(figsize = [6, 6])
plt.subplot(121)

# gini_list1[:-1]: exclude the last element in list
# range(1,9): exclude 9, means [1,8]
plt.bar(range(1,9) ,gini_list1[:-1], label = 'Social Influence')
# last element
plt.bar(9, gini_list1[-1], label = 'Independent')

plt.ylabel('Gini Coefficients', fontsize = 20)
plt.legend()
plt.ylim([0, 0.6])
plt.title('Experiment 1')

plt.subplot(122)
plt.bar(range(1,9) ,gini_list1[:-1])
plt.bar(9, gini_list1[-1])
plt.ylim([0, 0.6])
plt.title('Experiment 2')
plt.tight_layout()

# Figure2
import itertools
for i in itertools.combinations(worlds[:-1], 2):
    print(i)

import numpy as np
def get_U(df):
    u_list = []
    for i in df.index:
        song = df['song_id'][i]
        song_diff = 0
        num = 0
        for j,k in itertools.combinations(worlds[:-1], 2):
            mij = df[j][i]/df[j].sum()
            mik = df[k][i]/df[k].sum()
            song_diff += abs(mij-mik)
            num += 1
        ui = song_diff/num
        u_list.append(ui) 
    U = np.sum(u_list)/len(u_list)
    return U

U1, U2 = get_U(df1), get_U(df2)

columns = ['user_id', 'world_id']
for i in range(1, 49):
    columns.append('song_'+str(i))
columns

df1w9 = pd.read_csv(f'{file_path}dynamics_downloads_w9_v1.txt', skiprows=8, names = columns)
# load dynamics_downloads_w9_v2.txt
df2w9 = pd.read_csv(f'{file_path}dynamics_downloads_w9_v2.txt', skiprows=8, names = columns)

df1w9[:3]

import random

def get_split_U(df_independent):
    sample1 = random.sample(df_independent.index.tolist(), round(len(df_independent)/2) )
    sample2 = [i for i in df_independent.index if i not in sample1]

    dat1 = df_independent[df_independent.index.isin(sample1)]
    dat2 = df_independent[df_independent.index.isin(sample2)]

    songs = ['song_'+str(i) for i in range(1, 49)]
    dij = [dat1[i].sum() for i in songs]
    dik = [dat2[i].sum() for i in songs]

    mij = [i/np.sum(dij) for i in dij]
    mik = [i/np.sum(dik) for i in dik]
    u_list = abs(np.array(mij)-np.array(mik))
    U = np.sum(u_list)/len(u_list)
    return U

U_independent_2 =[] 
# 写一个for循环计算U_independent_2 
for i in range(1000):
    if i % 100 == 0:
        print(i)
    U_independent_2.append(get_split_U(df2w9))

plt.figure(figsize = [6, 6])

plt.subplot(121)
plt.bar(1, U1, label = 'Social Influence')
plt.bar(2, np.mean(U_independent_1), label = 'Independent')
plt.ylabel('Unpredictability U', fontsize = 20)
plt.legend()
plt.ylim([0, 0.015])
plt.title('Experiment 1')

plt.subplot(122)
plt.bar(1, U2, label = 'Social Influence')
plt.bar(2, np.mean(U_independent_2), label = 'Independent')
plt.ylim([0, 0.015])
plt.title('Experiment 2')
plt.tight_layout()

from scipy import stats
# 使用ttest_1samp对U_independent_1, U1进行t检验
r = stats.ttest_1samp(U_independent_1, U1, axis=0)
print("statistic:", r.__getattribute__("statistic"))
print("pvalue:", r.__getattribute__("pvalue"))

# 使用ttest_1samp对U_independent_2, U2进行t检验
r = stats.ttest_1samp(U_independent_2, U2, axis=0)
print("statistic:", r.__getattribute__("statistic"))
print("pvalue:", r.__getattribute__("pvalue"))

# 使用ttest_ind对U_independent_1, U_independent_2进行t检验
r = stats.ttest_ind(U_independent_1, U_independent_2)
print("statistic:", r.__getattribute__("statistic"))
print("pvalue:", r.__getattribute__("pvalue"))

# Figure3
import scipy.stats as ss

worlds = ['downloads_in_world1',
    'downloads_in_world2', 'downloads_in_world3',
    'downloads_in_world4', 'downloads_in_world5', 
    'downloads_in_world6', 'downloads_in_world7', 
    'downloads_in_world8', 'downloads_in_world_independent'] 


data1 = []

data1_rank = []
for i in df1.index:
    for j in worlds[:-1]:
        m_inf = df1[j][i]/df1[j].sum()
        m_ind = df1[worlds[-1]][i]/df1[worlds[-1]].sum()
        
        m_inf_rank = ss.rankdata(df1[j])[i]
        m_ind_rank = ss.rankdata(df1[worlds[-1]])[i]
        data1.append((m_inf, m_ind ))
        data1_rank.append((m_inf_rank, m_ind_rank))


data2 = []
data2_rank = []
# Write the for loop to get data2 and data2_rank
for i in df2.index:
    for j in worlds[:-1]:
        m_inf = df2[j][i]/df2[j].sum()
        m_ind = df2[worlds[-1]][i]/df2[worlds[-1]].sum()
        m_inf_rank = ss.rankdata(df2[j])[i]
        m_ind_rank = ss.rankdata(df2[worlds[-1]])[i]
        data2.append((m_inf, m_ind ))
        data2_rank.append((m_inf_rank, m_ind_rank))


m_infs1 = [i for i,j in data1]
m_inds1 = [j for i,j in data1]
m_infs2 = [i for i,j in data2]
m_inds2 = [j for i,j in data2]

m_infs1_rank = [i for i,j in data1_rank]
m_inds1_rank = [j for i,j in data1_rank]
m_infs2_rank = [i for i,j in data2_rank]
m_inds2_rank = [j for i,j in data2_rank]

plt.figure(figsize = [8, 8])

plt.subplot(221)
plt.plot(m_inds1, m_infs1, 'bo', label ='Exp.1')
plt.ylim([0, 0.2])
plt.xlim([0, 0.05])
plt.ylabel('$m_{influence}$', fontsize = 20)
plt.xlabel('$m_{indep}$', fontsize = 20)
plt.legend(loc='upper left')

plt.subplot(222)
plt.plot(m_inds1_rank, m_infs1_rank, 'bo', label ='Exp.1')
plt.ylabel('$Rank: m_{influence}$', fontsize = 20)
plt.xlabel('$Rank: m_{indep}$', fontsize = 20)

plt.legend(loc='upper left')

plt.subplot(223)
plt.plot(m_inds2, m_infs2, 'bo', label ='Exp.2')
plt.ylim([0, 0.2])
plt.xlim([0, 0.05])
plt.ylabel('$m_{influence}$', fontsize = 20)
plt.xlabel('$m_{indep}$', fontsize = 20)
plt.legend(loc='upper left')

plt.subplot(224)
plt.plot(m_inds2_rank, m_infs2_rank, 'bo', label ='Exp.2')
plt.ylabel('$Rank: m_{influence}$', fontsize = 20)
plt.xlabel('$Rank: m_{indep}$', fontsize = 20)

plt.legend(loc='upper left')

plt.tight_layout()
