import json


key_to_chinese = {
    'media_type': '媒体类型',
    'stream_index': '流索引',
    'key_frame': '关键帧',
    'pts': '呈现时间戳',
    'pts_time': '呈现时间戳时间',
    'pkt_dts': '解码时间戳',
    'pkt_dts_time': '解码时间戳时间',
    'best_effort_timestamp': '最佳努力时间戳',
    'best_effort_timestamp_time': '最佳努力时间戳时间',
    'pkt_duration': '数据包持续时间',
    'pkt_duration_time': '数据包持续时间时间',
    'duration': '持续时间',
    'duration_time': '持续时间时间',
    'pkt_pos': '数据包位置',
    'pkt_size': '数据包大小',
    'width': '宽度',
    'height': '高度',
    'pix_fmt': '像素格式',
    'sample_aspect_ratio': '采样长宽比',
    'pict_type': '帧类型',
    'coded_picture_number': '编码图片数量',
    'display_picture_number': '显示图片数量',
    'interlaced_frame': '隔行扫描帧',
    'top_field_first': '顶场优先',
    'repeat_pict': '重复图片',
    'chroma_location': '色度位置',
    'side_data_list': '边数据列表',
    'side_data_type': '边数据类型',
}


def print_frame_info(frame):
    # 打印帧的基本信息
    for key, value in frame.items():
        if key != 'side_data_list':  # 略过这个字段，稍后处理
            # 获取键对应的中文描述，如果没有找到则使用英文键
            chinese_key = key_to_chinese.get(key, key)
            print(f'{chinese_key}（{key}）: {value}')

    # 如果存在 'side_data_list' 字段，分别打印其每个元素
    if 'side_data_list' in frame:
        chinese_key = key_to_chinese.get('side_data_list', 'side_data_list')
        print(f'{chinese_key}（side_data_list）:')
        for i, side_data in enumerate(frame['side_data_list']):
            for key, value in side_data.items():
                # 获取键对应的中文描述，如果没有找到则使用英文键
                chinese_key = key_to_chinese.get(key, key)
                print(f'  item {i}: {chinese_key}（{key}）: {value}')


# 使用 open() 函数打开并读取名为 'output.json' 的文件，将文件内容载入 'data' 变量中
with open('frames.json') as f:
    data = json.load(f)

# 遍历 'data' 中的每一帧数据
for frame in data['frames']:
    # 只处理视频帧数据，因此检查 'media_type' 是否为 'video'
    if frame['media_type'] == 'video':
        print_frame_info(frame)
        # 打印分隔线
        print('------------------------------------')
